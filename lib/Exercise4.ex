defmodule Exercise4 do
  require Integer
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

  @spec get_starting_points_indices(String.t(), String.t()) :: [integer()]
  defp get_starting_points_indices(str_lines, starting_point) do
    str_lines
    |> String.split("")
    |> Enum.with_index()
    |> Enum.filter(fn {char, _index} -> char === starting_point end)
    |> Enum.map(fn {_char, index} -> index - 1 end)
  end

  @spec scan_words_around(list(String.t()), String.t(), integer(), integer()) :: integer()
  defp scan_words_around(lines, word, x, y) do
    allowed_dirs = [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    allowed_dirs |> Enum.count(fn {dir_x, dir_y} -> has_word_in_dir(lines, word, x, y, dir_x, dir_y) end)
  end

  @spec count_instances_of_word(list(String.t()), list(integer())) :: non_neg_integer()
  defp count_instances_of_word(lines, indices), do: lines |> count_instances_of_word(indices, "XMAS")

  @spec count_instances_of_word(list(String.t()), list(integer()), String.t()) :: non_neg_integer()
  defp count_instances_of_word(lines, indices, word) do
    index = hd(indices)
    x = rem(index, String.length(hd(lines)))
    y = div(index, length(lines))
    output = scan_words_around(lines, word, x, y)

    if (length(indices) > 1) do
      output + count_instances_of_word(lines, tl(indices), word)
    else
      output
    end
  end

  @spec cross_diagonal(list(String.t()), String.t(), {integer(), integer()}, {integer(), integer()}) :: boolean()
  defp cross_diagonal(lines, word, {x, y}, {dir_x, dir_y}), do: cross_diagonal(lines, word, {x, y}, {dir_x, dir_y}, 0)

  @spec cross_diagonal(list(String.t()), String.t(), {integer(), integer()}, {integer(), integer()}, integer()) :: boolean()
  defp cross_diagonal(lines, word, {x, y}, {dir_x, dir_y}, deepness) do
    word_center = div(String.length(word), 2)
    if (deepness > word_center) do
      true
    else
      if (String.length(word) |> Integer.is_even() or is_outside(lines, x - dir_x, y - dir_y) or is_outside(lines, x + dir_x, y + dir_y)) do
        false
      else
        prev_dir_x = dir_x * deepness
        prev_dir_y = dir_y * deepness
        chars_to_find = String.at(word, word_center - deepness) <> String.at(word, word_center + deepness)
        first_char_in_lines = lines |> Enum.at(y - prev_dir_y) |> String.at(x - prev_dir_x)
        last_char_in_lines = lines |> Enum.at(y + prev_dir_y) |> String.at(x + prev_dir_x)
        chars_in_lines = first_char_in_lines <> last_char_in_lines
        if (chars_to_find === chars_in_lines or chars_to_find === String.reverse(chars_in_lines)) do
          cross_diagonal(lines, word, {x, y}, {dir_x, dir_y}, deepness + 1)
        else
          false
        end
      end
    end
  end

  @spec count_crossed_word(list(String.t()), list(integer())) :: non_neg_integer()
  defp count_crossed_word(lines, indices), do: lines |> count_crossed_word(indices, "MAS")

  @spec count_crossed_word(list(String.t()), list(integer()), String.t()) :: non_neg_integer()
  defp count_crossed_word(lines, indices, word) do
    index = hd(indices)
    x = rem(index, String.length(hd(lines)))
    y = div(index, length(lines))
    first_cross = cross_diagonal(lines, word, {x, y}, {-1, -1})
    second_cross = cross_diagonal(lines, word, {x, y}, {1, -1})
    output = if first_cross and second_cross do 1 else 0 end

    if (length(indices) > 1) do
      output + count_crossed_word(lines, tl(indices), word)
    else
      output
    end
  end

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex1(lines) do
    indices = lines |> Enum.join() |> get_starting_points_indices("X")
    lines |> count_instances_of_word(indices)
  end

  @spec ex2(list(String.t())) :: non_neg_integer()
  def ex2(lines) do
    indices = lines |> Enum.join() |> get_starting_points_indices("A")
    lines |> count_crossed_word(indices)
  end
end
