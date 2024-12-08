defmodule Exercise8 do
  @type vector() :: {integer(), integer()}
  @type infinite_integer() :: non_neg_integer() | :infinity

  @spec get_map_dimensions([String.t()]) :: vector()
  defp get_map_dimensions(lines), do: {hd(lines) |> String.length(), length(lines)}

  @spec find_antenna_frequencies([String.t()], String.t()) :: [String.t()]
  defp find_antenna_frequencies(lines, excluded) do
    lines
    |> Enum.join()
    |> String.split("", trim: true)
    |> Enum.filter(fn char -> char !== excluded end) |> Enum.uniq()
  end

  @spec get_antenna_positions([String.t()], String.t()) :: [vector()]
  defp get_antenna_positions(lines, frequency) do
    width = hd(lines) |> String.length()
    lines
    |> Enum.join()
    |> String.split(frequency)
    |> Enum.reduce([-1], fn cur, acc -> acc ++ [hd(Enum.take(acc, -1)) + String.length(cur) + 1] end)
    |> tl() |> Enum.reverse() |> tl() |> Enum.reverse()
    |> Enum.map(fn index -> {rem(index, width), div(index, width)} end)
  end

  @spec compute_antinode(vector(), vector(), vector(), infinite_integer()) :: [vector()]
  defp compute_antinode(p1, p2, dimensions, max_depth), do: compute_antinode(p1, p2, dimensions, max_depth, 1)

  @spec compute_antinode(vector(), vector(), vector(), integer(), infinite_integer()) :: [vector()]
  defp compute_antinode({x1, y1}, {x2, y2}, {width, height}, max_depth, depth) do
    if (depth - 1 >= max_depth) do
      []
    else
      {px1, py1} = {x2 + (x2 - x1) * depth, y2 + (y2 - y1) * depth}
      {px2, py2} = {x1 - (x2 - x1) * depth, y1 - (y2 - y1) * depth}
      array = if (px1 >= 0 and py1 >= 0 and px1 < width and py1 < height) do [{px1, py1}] else [] end
      ++ if (px2 >= 0 and py2 >= 0 and px2 < width and py2 < height) do [{px2, py2}] else [] end
      if (length(array) === 0) do
        []
      else
        array ++ compute_antinode({x1, y1}, {x2, y2}, {width, height}, max_depth, depth + 1)
      end
    end
  end

  @spec compute_antinodes([vector()], vector(), infinite_integer()) :: [vector()]
  defp compute_antinodes(positions, dimensions, max_depth) do
    if (length(positions) <= 1) do
      []
    else
      (hd(positions) |> compute_antinode(hd(tl(positions)), dimensions, max_depth))
      ++ compute_antinodes(tl(positions), dimensions, max_depth)
      ++ compute_antinodes([hd(positions)] ++ tl(tl(positions)), dimensions, max_depth)
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    dimensions = get_map_dimensions(lines)
    lines |> find_antenna_frequencies(".")
    |> Enum.flat_map(fn frequency -> get_antenna_positions(lines, frequency) |> compute_antinodes(dimensions, 1) end)
    |> Enum.uniq()
    |> length()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    dimensions = get_map_dimensions(lines)
    lines |> find_antenna_frequencies(".")
    |> Enum.flat_map(fn frequency -> (get_antenna_positions(lines, frequency) |> compute_antinodes(dimensions, :infinity)) ++ get_antenna_positions(lines, frequency) end)
    |> Enum.uniq()
    |> length()
  end
end
