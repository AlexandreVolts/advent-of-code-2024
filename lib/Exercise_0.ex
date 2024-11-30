defmodule Exercise_0 do
  @spec get_number_from_first_and_last_char(binary()) :: integer()
  def get_number_from_first_and_last_char(str) do
    str = Regex.replace(~r/[[:alpha:]]/, str, "")
    (String.first(str) <> String.last(str)) |> String.to_integer()
  end

  @spec extract_number_from_str(binary()) :: binary()
  def extract_number_from_str(str) do
    numbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    numbers |> Enum.with_index() |> Enum.reduce(str, fn {x, index}, acc -> String.replace(acc, x, x <> Integer.to_string(index + 1) <> x) end)
  end

  @spec ex1(list()) :: integer()
  def ex1(lines) do
    lines |> Enum.reduce(0, fn x, acc -> acc + Exercise_0.get_number_from_first_and_last_char(x) end)
  end

  @spec ex2(list()) :: integer()
  def ex2(lines) do
    lines |> Enum.map(fn x -> Exercise_0.extract_number_from_str(x) end) |> Exercise_0.ex1()
  end
end
