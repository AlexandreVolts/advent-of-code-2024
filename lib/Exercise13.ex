defmodule Exercise13 do
  @type pair :: {non_neg_integer(), non_neg_integer()}
  @type equation :: list(pair())

  @spec get_pair(String.t()) :: pair() | nil
  defp get_pair(line) do
    values = Regex.scan(~r/\d+/, line)
            |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
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

  @spec solve_equation(equation(), non_neg_integer(), boolean()) :: {non_neg_integer(), integer()} | nil
  defp solve_equation(equation, term, is_x) do
    {ax, ay} = hd(equation)
    {bx, by} = hd(tl(equation))
    {sx, sy} = hd(tl(tl(equation)))

    if (is_x) do
      if (rem(sx - ax * term, bx) !== 0) do
        nil
      else
        {term, div(sx - ax * term, bx)}
      end
    else
      if (rem(sy - ay * term, by) !== 0) do
        nil
      else
        {term, div(sy - ay * term, by)}
      end
    end
  end

  @spec get_equation_results(equation(), non_neg_integer(), boolean()) :: [{non_neg_integer(), integer()}]
  defp get_equation_results(equation, depth, is_x) do
    if (depth === 0) do
      []
    else
      result = solve_equation(equation, depth, is_x)
      (if result !== nil and result > 0 do [result] else [] end) ++ get_equation_results(equation, depth - 1, is_x)
    end
  end

  @spec get_button_pressions(equation()) :: {non_neg_integer() | nil, non_neg_integer() | nil}
  defp get_button_pressions(equation) do
    x_solutions = get_equation_results(equation, 100, true) |> IO.inspect()
    y_solutions = get_equation_results(equation, 100, false) |> IO.inspect()
    y_solutions |> Enum.find(fn y -> x_solutions |> Enum.member?(y) end) |> IO.inspect()
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    lines
    |> get_all_equations()
    |> Enum.map(fn equation -> Task.async(fn -> get_button_pressions(equation) end) end)
    |> Task.await_many()
    |> Enum.filter(fn pair -> pair !== nil end)
    |> Enum.reduce(0, fn {a, b}, acc -> acc + a * 3 + b end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines) do

  end
end
