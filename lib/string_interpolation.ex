defmodule StringInterpolation do
  require Operators
  import Operators

  @moduledoc """
    `<|>`: pipe-to-interpolation
    `~~~`: template-strings
  """

  defmacro left
           <|> ({name, info, _} = base) do
    new_args = interpolated_string(left, base)
    {name, info, new_args}
  end

  defmacro ~~~right do
    {:<<>>, line, _} = right
    token = {:token, line, nil}

    token
    ~> interpolated_string(_, right)
    ~> tokenize(:<<>>).(line).(_)
    ~> List.wrap(_)
    ~> List.insert_at(_,0,[token])
    ~> tokenize(:->).(line).(_)
    ~> List.wrap(_)
    ~> tokenize(:fn).(line).(_)
  end

  def tokenize(atom_part) do
    fn line -> fn arguments -> {atom_part, line, arguments} end end
  end

  def interpolated_string(new_value, {:<<>>, _, string_pieces}) do
    replace_node = fn value ->
      string_pieces
      ~> Enum.find_index(_,&(is_string_slot?(&1)))
      ~> List.replace_at(string_pieces,_,value)
    end

    string_pieces
    |> Enum.find(&is_string_slot?/1)
    |> (fn {:::, slot_context_outer, [old_slot, binary_type]} ->
        {:::, slot_context_outer, [old_slot, binary_type]}
        |> Tuple.to_list()
        |> List.last()
        |> List.first()
        |> Tuple.delete_at(2)
        |> Tuple.append([new_value])
        |> (&{:::, slot_context_outer, [&1, binary_type]}).()
      end).()
    |> replace_node.()
  end

  @doc """
    {:<<>>, _line, [{:::, _line, [{:_, _line, nil}]}, _]}
  """

  def is_string_slot?({_, _, [{_, _, [{:_, _, nil}]}, _]}), do: true
  def is_string_slot?(_), do: false
end