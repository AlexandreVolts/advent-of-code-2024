defmodule Exercise19 do
  use Memoize

  @spec is_starting_with?(String.t(), String.t()) :: boolean()
  defp is_starting_with?(pattern, towel), do: pattern |> String.slice(0..(String.length(towel) - 1)) === towel

  @spec cut_pattern(String.t(), String.t()) :: String.t()
  defp cut_pattern(pattern, towel), do: pattern |> String.slice(String.length(towel)..String.length(pattern))

  @spec count_pattern_occurences(String.t(), [String.t()]) :: non_neg_integer()
  defmemop count_pattern_occurences(pattern, towels) do
    if (String.length(pattern) === 0) do
      1
    else
      valid_towels = towels |> Enum.filter(fn towel -> is_starting_with?(pattern, towel) end)
      if (length(valid_towels) === 0) do
        0
      else
        valid_towels
        |> Enum.reduce(0, fn towel, acc -> acc + count_pattern_occurences(cut_pattern(pattern, towel), towels) end)
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    towels = hd(lines) |> String.split(", ")
    tl(tl(lines))
    |> Enum.map(fn pattern -> Task.async(fn -> count_pattern_occurences(pattern, towels) end) end)
    |> Task.await_many()
    |> Enum.filter(fn output -> output > 0 end)
    |> length()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    towels = hd(lines) |> String.split(", ")
    tl(tl(lines))
    |> Enum.map(fn pattern -> Task.async(fn -> count_pattern_occurences(pattern, towels) end) end)
    |> Task.await_many()
    |> Enum.reduce(0, fn x, acc -> acc + x end)
  end
end
