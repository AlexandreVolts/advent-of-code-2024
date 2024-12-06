defmodule Exercise5 do
  @spec extract_integers_from_char(list(String.t()), String.t()) :: list(list(integer()))
  defp extract_integers_from_char(lines, char) do
    lines |> Enum.filter(fn str -> str |> String.contains?(char) end)
    |> Enum.map(fn str -> str |> String.split(char, trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  @spec has_matching_pair?(list({integer(), integer()}), integer(), list(integer())) :: boolean()
  defp has_matching_pair?(page_order, left_value, instructions) do
    page_order
    |> Enum.any?(fn {left, right} -> left === left_value and (instructions |> Enum.member?(right)) end)
  end

  @spec is_valid_pair?(list({integer(), integer()}), {integer(), integer()}) :: boolean()
  defp is_valid_pair?(page_order, {left, right}) do
    page_order |> Enum.any?(fn {a, b} -> (a === left and b === right) end)
  end

  @spec is_instruction_valid(list({integer(), integer()}), list(integer())) :: boolean()
  defp is_instruction_valid(page_order, instruction) do
    if (length(instruction) <= 1) do
      true
    else
      if (!is_valid_pair?(page_order, {hd(instruction), hd(tl(instruction))})) do
        false
      else
        is_instruction_valid(page_order, tl(instruction))
      end
    end
  end

  @spec reorder_invalid_instruction(list({integer(), integer()}), list(integer())) :: list(integer())
  defp reorder_invalid_instruction(page_order, instruction) do
      if (length(instruction) === 1) do
        instruction
      else
        last = instruction |> Enum.find(fn left_value -> !has_matching_pair?(page_order, left_value, instruction) end)
        [last] ++ reorder_invalid_instruction(page_order, instruction |> Enum.filter(fn n -> n !== last end))
      end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    page_order = lines |> extract_integers_from_char("|") |> Enum.map(fn elem -> {hd(elem), hd(tl(elem))} end)
    lines
    |> extract_integers_from_char(",")
    |> Enum.filter(fn instruction -> is_instruction_valid(page_order, instruction) end)
    |> Enum.reduce(0, fn instruction, acc -> acc + (instruction |> Enum.at(div(length(instruction), 2))) end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    page_order = lines |> extract_integers_from_char("|") |> Enum.map(fn elem -> {hd(elem), hd(tl(elem))} end)
    lines
    |> extract_integers_from_char(",")
    |> Enum.filter(fn instruction -> !is_instruction_valid(page_order, instruction) end)
    |> Enum.map(fn instruction -> reorder_invalid_instruction(page_order, instruction) end)
    |> Enum.reduce(0, fn instruction, acc -> acc + (instruction |> Enum.at(div(length(instruction), 2))) end)
  end
end
