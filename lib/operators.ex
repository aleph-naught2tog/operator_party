defmodule Operators do
  @slot :_

  @argument_index 2

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

  defmacro left ~>> input do
    input
    |> get_arguments()
    |> List.replace_at(-1, left)
    |> set_arguments(input)
  end

  defmacro left <<~ input do
    input
    |> get_arguments()
    |> List.replace_at(0, left)
    |> set_arguments(input)
  end

  defmacro left ~> input do
    input
    |> get_arguments()
    |> get_slot_index()
    |> (fn {args, pos} -> List.replace_at(args, pos, left) end).()
    |> set_arguments(input)
  end

  defp get_arguments(call) when is_tuple(call), do: elem(call, @argument_index)
  defp set_arguments(arguments, old_call), do: put_elem(old_call, @argument_index, arguments)

  defp get_slot_index(call) when is_tuple(call) do
    call
    |> get_arguments()
    |> get_slot_index()
  end

  defp get_slot_index(arguments) when is_list(arguments) do
    {arguments, Enum.find_index(arguments, &is_slot?/1)}
  end

  defp is_slot?(name, delimiter \\ @slot)
  defp is_slot?({name, _, _}, delimiter), do: name === delimiter
  defp is_slot?(_, _), do: false
end