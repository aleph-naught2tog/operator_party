defmodule OperatorPartyTest do
  use ExUnit.Case
  require Operators
  import Operators

  doctest OperatorParty

  describe "non-callables should fail" do
    # How realistic is this in something where everything is basically callable?
  end

  describe "one-arity functions should be equal for all operators" do
    test "pipe-to-end should equal |> when arity === 1" do
      result = "inner outer #{1 + 23} bears"

      result
      |> String.upcase()
      <|> "test #{_} pink blue"
      |> IO.inspect()

      arity_1_test_funcs()
      |> Enum.all?(fn {arg, func} ->
        operator_value = arg ~>> func.(_)
        normal_value = arg |> func.()
        operator_value === normal_value
      end)
    end

    test "pipe-alternative should equal |> when arity === 1" do
      arity_1_test_funcs()
      |> Enum.all?(fn {arg, func} ->
        operator_value = arg <<~ func.(_)
        normal_value = arg |> func.()
        operator_value === normal_value
      end)
    end

    test "pipe-to-position should equal |> when arity === 1" do
      arity_1_test_funcs()
      |> Enum.all?(fn {arg, func} ->
        operator_value = arg ~> func.(_)
        normal_value = arg |> func.()
        operator_value === normal_value
      end)
    end
  end

#  describe "pipe-alternative" do
#
#  end
#
#  describe "pipe-to-end" do
#
#  end

  test "smoke check" do
    assert true
  end

  def arity_1_test_funcs do
    [
      {"apples", &String.upcase/1},
      {45, &Integer.to_string/1},
      {["a","b","c"], &Enum.count/1}
    ]
  end
end
