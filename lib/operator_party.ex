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
    { # --- <FN_DEF> --- #
      :fn,
      LINE,
      [
        {
          :->,
          LINE,
          [
            [{:variable, LINE, nil}], # the token of the variable being input
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
                      [{:variable, LINE, nil}]
                    },
                    {:binary, LINE, nil}
                  ]
                },
                " apples"
              ] # --- </INTERPOLATION> --- #
            }
          ]
        }
      ] # --- </FN_DEF> --- #
    }
  end
end
