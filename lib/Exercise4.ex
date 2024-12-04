defmodule Exercise4 do
  @spec is_outside(list(String.t()), integer(), integer()) :: boolean()
  defp is_outside(lines, x, y) do
    x < 0 or y < 0 or y >= length(lines) or x >= Enum.at(lines, y) |> String.length()
  end

  defp has_word_in_dir(lines, word, x, y, dir_x, dir_y) do
    if (String.length(word) === 0) do
      true
    else
      if (is_outside(lines, x, y)) do
        false
      else
        if (Enum.at(lines, y) |> String.at(x) === String.first(word)) do
          has_word_in_dir(lines, String.slice(word, 1, String.length(word)), x + dir_x, y + dir_y, dir_x, dir_y)
        else
          false
        end
      end
    end
  end

  @spec scan_words_around(list(String.t()), String.t(), integer(), integer()) :: integer()
  defp scan_words_around(lines, word, x, y) do
    [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    |> Enum.count(fn {dir_x, dir_y} -> has_word_in_dir(lines, word, x, y, dir_x, dir_y) end)
  end

  @spec count_instances_of_word(list(String.t())) :: any()
  defp count_instances_of_word(lines), do: lines |> count_instances_of_word("XMAS", 0)

  @spec count_instances_of_word(list(String.t()), String.t(), integer()) :: any()
  defp count_instances_of_word(lines, word, index) do
    x = rem(index, String.length(hd(lines)))
    y = div(index, length(lines))
    len = length(lines) * (hd(lines) |> String.length())
    output = scan_words_around(lines, word, x, y)

    if (index < len) do
      output + count_instances_of_word(lines, word, index + 1)
    else
      output
    end
  end

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex1(lines), do: lines |> count_instances_of_word()

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex2(lines) do
    0
  end
end
