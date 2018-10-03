defmodule Operators do
  @doc """
    `~>>`: pipe-to-end
    `<<~`: pipe-alternative
    `~>`: pipe-to-position
  """

  defmacro left ~>> right do
    {name, info, args} = right
    new_args = List.replace_at(args, -1, left)
    {name, info, new_args}
  end

  defmacro left <<~ right do
    {name, info, args} = right
    new_args = List.replace_at(args, 0, left)
    {name, info, new_args}
  end

  defmacro left ~> right do
    {name, info, args} = right
    slot_index = get_slot_index(right)
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
    args
    |> Enum.find_index(&is_slot?/1)
  end

  defp is_slot?(_name, _delimiter \\ :_)
  defp is_slot?({name, _, _}, delimiter), do: name === delimiter
  defp is_slot?(_,_), do: false
end