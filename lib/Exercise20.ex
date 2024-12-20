defmodule Exercise20 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}
  @type non_neg_vector3() :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}
  @type shortcut() :: {non_neg_vector(), non_neg_vector()}

  @spec get_next_position([non_neg_vector()], non_neg_vector()) :: non_neg_vector() | nil
  defp get_next_position(positions, {x, y}) do
    around = Utils.get_positions_around({x, y})
    positions |> Enum.find(fn pos -> Enum.member?(around, pos) end)
  end

  @spec get_path_with_indexes([non_neg_vector()], non_neg_vector(), non_neg_vector()) :: [non_neg_vector3()]
  defp get_path_with_indexes(positions, {start_x, start_y}, {x, y}) do
    if (length(positions) <= 1) do
      [{x, y, 1}, {start_x, start_y, 0}]
    else
      {nx, ny} = get_next_position(positions, {x, y})
      next_positions = positions |> List.delete({x, y})
      [{x, y, length(positions)}] ++ get_path_with_indexes(next_positions, {start_x, start_y}, {nx, ny})
    end
  end

  @spec get_obstacle_adjacent_spaces([String.t()], non_neg_vector()) :: shortcut() | nil
  defp get_obstacle_adjacent_spaces(lines, {x, y}) do
    if (Utils.at(lines, x - 1, y) === Utils.at(lines, x + 1, y) and Utils.at(lines, x - 1, y) === ".") do
      {{x - 1, y}, {x + 1, y}}
    else
      if (Utils.at(lines, x, y - 1) === Utils.at(lines, x, y + 1) and Utils.at(lines, x, y - 1) === ".") do
        {{x, y - 1}, {x, y + 1}}
      else
        nil
      end
    end
  end

  @spec get_filtered_obstacles([String.t()]) :: [shortcut()]
  defp get_filtered_obstacles(lines) do
    cleaned_lines = lines
    |> Enum.join("\n")
    |> String.replace("E", ".")
    |> String.replace("S", ".")
    |> String.split("\n")
    lines
    |> Utils.get_char_positions_in_map("#")
    |> Enum.map(fn obstacle -> get_obstacle_adjacent_spaces(cleaned_lines, obstacle) end)
    |> Enum.filter(fn obstacle -> obstacle !== nil end)
  end

  @spec get_shortcut_distance([non_neg_vector3()], shortcut()) :: non_neg_integer() | nil
  defp get_shortcut_distance(positions, {{sx, sy}, {ex, ey}}) do
    {_x, _y, d1} = positions |> Enum.find(fn {x, y, _index} -> x === sx and y === sy end)
    {_x, _y, d2} = positions |> Enum.find(fn {x, y, _index} -> x === ex and y === ey end)
    abs(d2 - d1)
  end

  @spec get_shortcuts_distances([non_neg_vector3()], [shortcut()]) :: [non_neg_integer()]
  defp get_shortcuts_distances(positions, obstacles) do
    if (length(obstacles) === 0) do
      []
    else
      [get_shortcut_distance(positions, hd(obstacles))] ++ get_shortcuts_distances(positions, tl(obstacles))
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    positions = lines |> Utils.get_char_positions_in_map(".")
    obstacles = get_filtered_obstacles(lines)
    start = lines |> Utils.get_char_positions_in_map("S") |> hd()
    final = lines |> Utils.get_char_positions_in_map("E") |> hd()
    get_path_with_indexes(positions ++ [final], start, final)
    |> get_shortcuts_distances(obstacles)
    |> Enum.filter(fn x -> x > 101 end)
    |> length()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    0
  end
end
