defmodule OperatorParty do
  require Operators

  def run() do

  end

  def template do
    _LINE = [line: 70]
    temp = "_" # this is so we compile.
    _interp = "I have #{temp} apples"
    {
      :<<>>,
      LINE,
      [
        "I have ",
        {
          :::,
          LINE,
          [
            {
              {:., LINE, [Kernel, :to_string]},
              LINE,
              [{:_, LINE, nil}]
            },
            {:binary, LINE, nil}
          ]
        },
        # ---- closes :: block
        " apples"
      ]
    } # ---- closes <<>> block
  end

  def anonymous do
    _LINE = [line: 69]
    _temp = fn variable -> "I have #{variable} apples" end

    variable_for_token = {:variable, LINE, nil} # the token of the variable being input
    interp_for_variable =
      { # --- <INTERPOLATION> --- #
        :<<>>,
        LINE,
        [
          "I have ",
          {
            :::,
            LINE,
            [
              {
                {:., LINE, [Kernel, :to_string]},
                LINE,
                [variable_for_token]
              },
              {:binary, LINE, nil}
            ]
          },
          " apples"
        ] # --- </INTERPOLATION> --- #
      }

    { # --- <FN_DEF> --- #
      :fn,
      LINE,
      [
        {
          :->,
          LINE,
          [
            variable_for_token,
            interp_for_variable
          ]
        }
      ] # --- </FN_DEF> --- #
    }





    {:fn, [],
      [
        {:->, [],
          [
            [{:token, [], StringInterpolation}],
            {:<<>>, [],
              [
                "oranges and ",
                {:::, [],
                  [
                    {{:., [], [Kernel, :to_string]}, [],
                      [{:token, [], StringInterpolation}]},
                    {:binary, [], StringInterpolation}
                  ]}
              ]}
          ]}
      ]}

    {:fn, [line: 71],
      [
        {:->, [line: 71],
          [
            {:token, [line: 71], nil},
            [
              "oranges and ",
              {:::, [line: 71],
                [
                  {{:., [line: 71], [Kernel, :to_string]}, [line: 71],
                    [{:token, [line: 71], nil}]},
                  {:binary, [line: 71], nil}
                ]}
            ]
          ]}
      ]}
  end
end
