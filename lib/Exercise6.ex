defmodule Exercise6 do
  @type vector :: {integer(), integer()}

  @spec get([String.t()], vector()) :: String.t() | nil
  defp get(lines, {x, y}) do
    if (x < 0 or y < 0 or x >= hd(lines) |> String.length() or y >= length(lines)) do
      nil
    else
      lines |> Enum.at(y) |> String.at(x)
    end
  end

  @spec get_dir_from_rotation(integer()) :: vector()
  defp get_dir_from_rotation(rotation) do
    case rem(rotation, 4) do
      1 -> {1, 0}
      2 -> {0, 1}
      3 -> {-1, 0}
      _ -> {0, -1}
    end
  end

  @spec walk([String.t()], String.t(), String.t()) :: list(vector())
  defp walk(lines, guard, obstacle) do
    index = Enum.join(lines) |> String.split(guard) |> hd() |> String.length()
    width = hd(lines) |> String.length()

    walk(lines, {rem(index, width), div(index, width)}, 0, obstacle)
  end

  @spec walk([String.t()], vector(), integer(), String.t()) :: list(vector())
  defp walk(lines, {x, y}, rotation, obstacle) do
    {dir_x, dir_y} = get_dir_from_rotation(rotation)
    next = get(lines, {x + dir_x, y + dir_y})

    if (next === nil) do
      [{x, y}]
    else
      if (next === obstacle) do
        [{x, y}] ++ walk(lines, {x, y}, rotation + 1, obstacle)
      else
        [{x, y}] ++ walk(lines, {x + dir_x, y + dir_y}, rotation, obstacle)
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines), do: lines |> walk("^", "#") |> Enum.uniq() |> length()

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines), do: 0
end
