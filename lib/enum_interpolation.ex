defmodule EnumInterpolation do
  @moduledoc """
  `|||`: pipe-enum
  """

  defmacro left ||| right do
    left |> IO.inspect()
  end

end