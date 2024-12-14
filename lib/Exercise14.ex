defmodule Exercise14 do
  @type vector :: {integer(), integer()}
  @type robot :: {vector(), vector()}

  @spec get_robot(String.t()) :: robot()
  defp get_robot(line) do
    values = Regex.scan(~r/\-?\d+/, line) |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
    {{hd(values), hd(tl(values))}, {hd(tl(tl(values))), hd(tl(tl(tl(values))))}}
  end

  @spec move_robot(robot(), vector(), non_neg_integer()) :: vector()
  defp move_robot({{x, y}, {vx, vy}}, {width, height}, seconds) do
    tmp_x = rem(x + vx * seconds, width)
    tmp_y = rem(y + vy * seconds, height)
    nx = if (tmp_x < 0) do width + tmp_x else tmp_x end
    ny = if (tmp_y < 0) do height + tmp_y else tmp_y end
    {nx, ny}
  end

  @spec sign(integer()) :: -1 | 0 | 1
  defp sign(x) do
    cond do
      x < 0 -> -1
      x > 0 -> 1
      true -> 0
    end
  end

  @spec vector_to_cluster(vector(), vector()) :: vector()
  defp vector_to_cluster({x, y}, {width, height}) do
    {sign(x - div(width, 2)), sign(y - div(height, 2))}
  end

  @spec clusterize([vector()], vector()) :: map()
  defp clusterize(positions, dimensions) do
    if (length(positions) === 0) do
      %{}
    else
      {x, y} = vector_to_cluster(hd(positions), dimensions)
      map = clusterize(tl(positions), dimensions)
      if (x === 0 or y === 0) do
        map
      else
        {_cur, new_map} = Map.get_and_update(map, {x, y}, fn x -> {x, if (x === nil) do 1 else x + 1 end} end)
        new_map
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    dimensions = {101, 103}
    lines
    |> Enum.map(&get_robot/1)
    |> Enum.map(fn robot -> move_robot(robot, dimensions, 100) end)
    |> clusterize(dimensions) |> Map.values()
    |> Enum.reduce(1, fn x, acc -> acc * x end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines), do: 0
end
