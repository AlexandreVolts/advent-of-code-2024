defmodule Exercise1 do
  @spec get_integer_from_line(binary(), non_neg_integer()) :: integer()
  defp get_integer_from_line(line, index) do
    line |> String.split(" ", trim: true) |> Enum.at(index) |> String.to_integer()
  end

  @spec get_sorted_integer_list(list(charlist()), non_neg_integer()) :: list(integer())
  defp get_sorted_integer_list(lines, index) do
    lines |> Enum.map(fn line -> get_integer_from_line(line, index) end) |> Enum.sort()
  end

  @spec ex1(list(charlist())) :: integer()
  def ex1(lines) do
    l1 = lines |> get_sorted_integer_list(0)
    l2 = lines |> get_sorted_integer_list(1)

    l1 |> Enum.with_index() |> Enum.reduce(0, fn {x, index}, acc -> acc + abs(x - (l2 |> Enum.at(index))) end)
  end

  @spec ex2(list(charlist())) :: integer()
  def ex2(lines) do
    l1 = lines |> get_sorted_integer_list(0)
    l2 = lines |> get_sorted_integer_list(1)

    l1 |> Enum.reduce(0, fn x, acc -> acc + x * (l2 |> Enum.count(fn y -> x == y end)) end)
  end
end
