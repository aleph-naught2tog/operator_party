defmodule Operators do
  @type value :: any
  @type callable :: fun
  @type arguments :: [] | maybe_improper_list(ast_node, any)
  @type ast_node :: {atom, list, arguments}

  @moduledoc """
    These operators are intended to enhance the functionality of the pipe operator,
    by allowing things like piping to a particular argument, piping to the final argument,
    piping into string interpolation, etc.

    For all of these, you _must_ use explicit placeholders -- even the ones with a
    known index, such as the `~>>` or `<<~`.

    For example, say we wanted to replace all instances of the word "dog" with
    the upper-cased version.

        iex> subject = "There sure are a lot of dogs here at the Dog hotel!"
        iex> dog_regex = ~r/dogs?/i
        iex> subject ~> Regex.replace(dog_regex, _, fn term -> String.upcase(term) end)
        "There sure are a lot of DOGS here at the DOG hotel!"

    `~>>`: pipe-to-end
    `<<~`: pipe-alternative
    `~>`: pipe-to-position
    `<|>`: pipe-to-interpolation
    `~~~`: template-strings
  """

  defmacro left ~>> {name, info, args} do
    new_args = List.replace_at(args, -1, left)
    {name, info, new_args}
  end

  defmacro left <<~ {name, info, args} do
    new_args = List.replace_at(args, 0, left)
    {name, info, new_args}
  end

  defmacro left ~> {name, info, args} do
    slot_index = get_slot_index(args)
    new_args = List.replace_at(args, slot_index, left)
    {name, info, new_args}
  end

  defmacro left <|> ({name, info, _} = base) do
    new_args = interpolated_string(left, base)
    {name, info, new_args}
  end

  defmacro ~~~right do
    # TODO
    # Basically, what I need here is for the interpolated part
    #   to become ready for binding into...
    # so really, this template string should return a function
    IO.inspect(right)

    right
  end

  defp do_args({_, _, args}), do: args

  defp get_slot_index(ast_func) when is_tuple(ast_func) do
    ast_func
    |> do_args()
    |> get_slot_index()
  end

  defp get_slot_index(args) when is_list(args) do
    Enum.find_index(args, &is_slot?/1)
  end

  defp is_slot?(_name, _delimiter \\ :_)
  defp is_slot?({name, _, _}, delimiter), do: name === delimiter
  defp is_slot?(_, _), do: false

  def interpolated_string(new_value, base) do
    {:<<>>, _, string_pieces} = base
    string_pieces
    |> Enum.find_index(&is_string_slot?/1)
    |> (&Enum.at(string_pieces, &1)).()

    slot_index = Enum.find_index(string_pieces, &is_string_slot?/1)
    {:::, slot_context_outer, [old_slot, binary_type]} = Enum.at(string_pieces, slot_index)

    {to_string_piece, slot_context, _} = old_slot
    new_slot = {to_string_piece, slot_context, [new_value]}
    new_chunk = {:::, slot_context_outer, [new_slot, binary_type]}

    List.replace_at(string_pieces, slot_index, new_chunk)
  end

  @doc """
    {:<<>>, _line, [{:::, _line, [{:_, _line, nil}]}, _]}
  """

  def is_string_slot?({_, _, [{_, _, [{:_, _, nil}]}, _]}), do: true
  def is_string_slot?(_), do: false
end