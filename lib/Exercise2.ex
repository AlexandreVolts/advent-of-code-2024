defmodule Exercise2 do
  @spec convert_to_integer_list([String.t()]) :: [integer()]
  defp convert_to_integer_list(line) do
    line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
  end

  @spec is_safe([integer()]) :: boolean()
  defp is_safe(numbers), do: is_safe(numbers, 0)

  @spec is_safe([integer()], integer()) :: boolean()
  defp is_safe(numbers, sign) do
    cur = hd(numbers)
    nxt_numbers = tl(numbers)
    diff = hd(nxt_numbers) - cur
    nxt_sign = if diff > 0 do 1 else -1 end
    is_faulted = abs(diff) > 3 or diff === 0 or (sign !== 0 and sign !== nxt_sign)

    if (is_faulted) do
      false
    else
      if (length(nxt_numbers) > 1) do is_safe(nxt_numbers, nxt_sign) else true end
    end
  end

  @spec is_loosely_safe([integer()]) :: boolean()
  defp is_loosely_safe(numbers) do
    numbers |> Enum.with_index() |> Enum.filter(fn {_x, index} -> is_safe(numbers |> List.delete_at(index)) end) |> length() > 0
  end

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex1(lines) do
    lines |> Enum.map(&convert_to_integer_list/1) |> Enum.filter(&is_safe/1) |> length()
  end

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex2(lines) do
    lines |> Enum.map(&convert_to_integer_list/1) |> Enum.filter(&is_loosely_safe/1) |> length()
  end
end
