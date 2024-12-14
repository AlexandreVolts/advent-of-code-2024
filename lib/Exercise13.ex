defmodule Exercise13 do
  @type pair :: {non_neg_integer(), non_neg_integer()}
  @type equation :: list(pair())
  @type solution :: {integer(), integer()}

  @spec get_pair(String.t()) :: pair() | nil
  defp get_pair(line) do
    values = Regex.scan(~r/\d+/, line) |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
    if (length(values) < 0) do
      nil
    else
      {hd(values), hd(tl(values))}
    end
  end

  @spec get_equation_terms(String.t(), String.t(), String.t()) :: equation()
  defp get_equation_terms(button_a, button_b, prize), do: [button_a, button_b, prize] |> Enum.map(&get_pair/1)

  @spec get_all_equations([String.t()]) :: [equation()]
  defp get_all_equations(lines) do
    if (length(lines) < 3) do
      []
    else
      [get_equation_terms(hd(lines), hd(tl(lines)), hd(tl(tl(lines))))] ++ get_all_equations(Enum.slice(lines, 4, length(lines)))
    end
  end

  # To understand this function (for my future self: yes, you did it without internet, GG):
  # Set the equation as an equation system where:
  # ax * x + bx * y = sx
  # ay * x + by * y = sy
  # Solve the equation by finding every operation required to find the value of x (substitution method).
  # The solution to this path is x = (bx * (sy - by * (sx / bx))) / (ay * bx - by * ax)
  # Once x is solved, y becomes simply: y = (sy - (ay * x)) / by
  @spec solve_equation(equation()) :: solution() | nil
  defp solve_equation(equation) do
    {ax, ay} = hd(equation)
    {bx, by} = hd(tl(equation))
    {sx, sy} = hd(tl(tl(equation)))

    x = round(bx * (sy - by * (sx / bx)) / (ay * bx - by * ax))
    y = round((sy - (ay * x)) / by)
    if ((ax * x + bx * y === sx and ay * x + by * y === sy)) do {x, y} else nil end
  end

  @spec bump_equation_term(equation(), non_neg_integer()) :: equation()
  defp bump_equation_term(equation, bumper) do
    {sx, sy} = hd(tl(tl(equation)))

    [hd(equation), hd(tl(equation)), {sx + bumper, sy + bumper}]
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    lines
    |> get_all_equations()
    |> Enum.map(fn equation -> solve_equation(equation) end)
    |> Enum.filter(fn pair -> pair !== nil end)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + a * 3 + b end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    lines
    |> get_all_equations()
    |> Enum.map(fn equation -> equation |> bump_equation_term(10000000000000) |> solve_equation() end)
    |> Enum.filter(fn pair -> pair !== nil end)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + a * 3 + b end)
  end
end
