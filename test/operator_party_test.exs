defmodule OperatorPartyTest do
  use ExUnit.Case
  require Operators
  import Operators

  doctest OperatorParty
  doctest Operators

  describe "non-callables should fail" do
    # How realistic is this in something where everything is basically callable? Hrm.
  end

  describe "one-arity functions should be equal for all operators" do
    @describetag :arity_equivalence
    test "pipe-to-end should equal |> when arity === 1" do
      arity_1_test_funcs()
      |> Enum.all?(
           fn {arg, func} ->
             operator_value = arg
                              ~>> func.(_)
             normal_value = arg
                            |> func.()
             operator_value === normal_value
           end
         )
    end

    test "pipe-alternative should equal |> when arity === 1" do
      arity_1_test_funcs()
      |> Enum.all?(
           fn {arg, func} ->
             operator_value = arg
                              <<~ func.(_)
             normal_value = arg
                            |> func.()
             operator_value === normal_value
           end
         )
    end

    test "pipe-to-position should equal |> when arity === 1" do
      arity_1_test_funcs()
      |> Enum.all?(
           fn {arg, func} ->
             operator_value = arg
                              ~> func.(_)
             normal_value = arg
                            |> func.()
             operator_value === normal_value
           end
         )
    end
  end

  describe "pipe-alternative" do
    @describetag :pipe_alternative
  end

  describe "pipe-to-end" do
    @describetag :pipe_to_end
  end

  describe "string interpolation" do
    @describetag :strings
    test "should interpolate correctly with one string variable" do
      color = "red"
      control = "I have #{color} apples"

      piped =
        color
        <|> "I have #{_} apples"

      assert piped === control
    end

    test "should be able to handle presence of other known variables" do
      color = "red"
      quality = "tasty"
      control = "I have #{color} apples that are #{quality}"

      piped =
        color
        <|> "I have #{_} apples that are #{quality}"

      assert piped === control
    end
  end

  test "smoke check" do
    assert true
  end

  def arity_1_test_funcs do
    [
      {"apples", &String.upcase/1},
      {45, &Integer.to_string/1},
      {["a", "b", "c"], &Enum.count/1}
    ]
  end
end
