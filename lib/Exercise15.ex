defmodule Exercise15 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}
  @type vector() :: {integer(), integer()}

  @spec get_direction_from_instruction(String.t()) :: vector()
  defp get_direction_from_instruction(char) do
    case char do
      "^" -> {0, -1}
      ">" -> {1, 0}
      "v" -> {0, 1}
      "<" -> {-1, 0}
    end
  end

  @spec get_instructions([String.t()]) :: [vector()]
  defp get_instructions(lines) do
    lines
    |> Enum.filter(fn line -> !(line |> String.contains?("#")) end)
    |> Enum.join()
    |> String.split("", trim: true)
    |> Enum.map(&get_direction_from_instruction/1)
  end

  @spec trim_map([String.t()]) :: [String.t()]
  defp trim_map(lines) do
    lines
    |> Enum.filter(fn line -> line |> String.contains?("#") end)
    |> Enum.map(fn line -> line |> String.slice(1..(String.length(line) - 2)) end)
    |> tl() |> Enum.reverse() |> tl() |> Enum.reverse()
  end

  @spec is_object_movable?(non_neg_vector(), vector(), [non_neg_vector()], [non_neg_vector()], non_neg_vector()) :: boolean()
  defp is_object_movable?({x, y}, {dir_x, dir_y}, obstacles, boxes, {width, height}) do
    nx = x + dir_x
    ny = y + dir_y
    if (nx < 0 or ny < 0 or nx >= width or ny >= height or (obstacles |> Enum.member?({nx, ny}))) do
      false
    else
      if (boxes |> Enum.member?({nx, ny})) do
        is_object_movable?({nx, ny}, {dir_x, dir_y}, obstacles, boxes, {width, height})
      else
        true
      end
    end
  end

  @spec move_boxes(non_neg_integer(), vector(), [non_neg_vector()]) :: [non_neg_vector()]
  defp move_boxes({x, y}, {dir_x, dir_y}, boxes) do
    nx = x + dir_x
    ny = y + dir_y
    if (boxes |> Enum.member?({nx, ny})) do
      next_boxes = (boxes |> Enum.filter(fn {bx, by} -> bx !== nx or by !== ny end))
      [{nx + dir_x, ny + dir_y}] ++ move_boxes({nx, ny}, {dir_x, dir_y}, next_boxes)
    else
      boxes
    end
  end

  @spec get_box_positions_after_robot_moved(non_neg_vector(), [non_neg_vector()], [non_neg_vector()], non_neg_vector(), [vector()]) :: [non_neg_vector()]
  defp get_box_positions_after_robot_moved({x, y}, obstacles, boxes, dimensions, instructions) do
    if (length(instructions) === 0) do
      boxes
    else
      {dir_x, dir_y} = hd(instructions)
      if (is_object_movable?({x, y}, {dir_x, dir_y}, obstacles, boxes, dimensions)) do
        next_boxes = move_boxes({x, y}, {dir_x, dir_y}, boxes)
        get_box_positions_after_robot_moved({x + dir_x, y + dir_y}, obstacles, next_boxes, dimensions, tl(instructions))
      else
        get_box_positions_after_robot_moved({x, y}, obstacles, boxes, dimensions, tl(instructions))
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    map = trim_map(lines)
    dimensions = Utils.get_map_dimensions(map)
    instructions = get_instructions(lines)
    obstacles = map |> Utils.get_char_positions_in_map("#")
    boxes = map |> Utils.get_char_positions_in_map("O")
    robot = map |> Utils.get_char_positions_in_map("@") |> hd()

    get_box_positions_after_robot_moved(robot, obstacles, boxes, dimensions, instructions) |> IO.inspect()
    |> Enum.reduce(0, fn {x, y}, acc -> acc + (x + 1) + (y + 1) * 100 end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines), do: 0
end
