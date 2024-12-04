defmodule Exercise0 do
  @spec get_integer_from_first_and_last_char(String.t()) :: integer()
  def get_integer_from_first_and_last_char(str) do
    str = Regex.replace(~r/[[:alpha:]]/, str, "")
    (String.first(str) <> String.last(str)) |> String.to_integer()
  end

  @spec extract_integer_from_str(String.t()) :: String.t()
  def extract_integer_from_str(str) do
    numbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    numbers |> Enum.with_index() |> Enum.reduce(str, fn {x, index}, acc -> acc |> String.replace(x, x <> Integer.to_string(index + 1) <> x) end)
  end

  @spec ex1(list(String.t())) :: integer()
  def ex1(lines) do
    lines |> Enum.reduce(0, fn x, acc -> acc + get_integer_from_first_and_last_char(x) end)
  end

  @spec ex2(list(String.t())) :: integer()
  def ex2(lines) do
    lines |> Enum.map(&extract_integer_from_str/1) |> ex1()
  end
end
