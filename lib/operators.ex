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
end