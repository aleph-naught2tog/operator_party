defmodule Operators do
  @type value :: any
  @type callable :: fun
  @type arguments :: [] | maybe_improper_list(ast_node, any)
  @type ast_node :: {atom, list, arguments}

  @doc """
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

  defmacro left <|> ({name, info, args} = base) do
    new_args = interpolated_string(left, base)
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
  defp is_slot?(_, _), do: false

  def interpolated_string(new_value, base) do
    {:<<>>, _ , string_pieces} = base
    find_slot = fn piece -> piece
    |> parse_piece()
    |> is_string_slot?() end

    slot_index = Enum.find_index(string_pieces, find_slot) |> IO.inspect()
    {:::, slot_context_outer, [old_slot,binary_type]} = Enum.at(string_pieces, slot_index)
    {to_string_piece, slot_context, _} = old_slot
    new_slot = {:::, slot_context_outer, [{to_string_piece, slot_context, [new_value]},binary_type]}

    List.replace_at(string_pieces, slot_index,new_slot)
  end

  defp parse_piece(piece) when is_binary(piece), do: piece
  defp parse_piece({_, _, glue_arguments}) do
    [{_, _, [slot]}, _] = glue_arguments
    slot
  end

  def is_string_slot?({:_,_,nil}), do: true
  def is_string_slot?(_), do: false
end