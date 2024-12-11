defmodule Exercise7 do
  @type equation :: {integer(), list(integer())}

  @spec parse_equation([String.t()]) :: equation()
  defp parse_equation(line) do
    [left, right] = line |> String.split(": ", parts: 2)
    {
      left |> String.to_integer(),
      right |> Utils.str_to_integer_list()
    }
  end

  @spec concat_numbers(integer(), integer()) :: integer()
  defp concat_numbers(a, b), do: "#{a}#{b}" |> String.to_integer()

  @spec count_equation_solutions(equation(), list(function())) :: integer()
  defp count_equation_solutions({solution, numbers}, functions) do
    if (hd(numbers) > solution) do
      0
    else
      if (length(numbers) === 1) do
        if hd(numbers) === solution do 1 else 0 end
      else
        left = hd(numbers)
        right = hd(tl(numbers))
        functions |> Enum.reduce(0, fn func, acc -> acc + count_equation_solutions({solution, [func.(left, right)] ++ tl(tl(numbers))}, functions) end)
      end
    end
  end

  @spec spawn_task(equation(), list(function())) :: Task.t()
  defp spawn_task({solution, numbers}, functions) do
    Task.async(fn -> if count_equation_solutions({solution, numbers}, functions) > 0 do solution else 0 end end)
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    tasks = lines
    |> Enum.map(&parse_equation/1)
    |> Enum.map(fn equation -> spawn_task(equation, [&+/2, &*/2]) end)

    Task.await_many(tasks) |> Enum.sum()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    tasks = lines
    |> Enum.map(&parse_equation/1)
    |> Enum.map(fn equation -> spawn_task(equation, [&+/2, &*/2, &concat_numbers/2]) end)

    Task.await_many(tasks) |> Enum.sum()
  end
end
