defmodule Exercise15 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}
  @type vector() :: {integer(), integer()}
  @type box_list() :: {[non_neg_vector()], non_neg_integer()}

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

  @spec get_box(non_neg_vector(), box_list()) :: non_neg_vector() | nil
  defp get_box({x, y}, {boxes, box_width}) do
    boxes |> Enum.find(fn {bx, by} -> bx <= x and bx > x - box_width and by === y end)
  end

  @spec is_object_movable?(non_neg_vector(), vector(), [non_neg_vector()], box_list(), non_neg_vector()) :: boolean()
  defp is_object_movable?({x, y}, {dir_x, dir_y}, obstacles, {boxes, box_width}, {width, height}) do
    nx = x + dir_x
    ny = y + dir_y
    if (nx < 0 or ny < 0 or nx >= width or ny >= height or (obstacles |> Enum.member?({nx, ny}))) do
      false
    else
      box = get_box({nx, ny}, {boxes, box_width})
      if (box !== nil) do
        if (dir_x !== 0) do
          is_object_movable?({nx + (box_width - 1) * dir_x, y}, {dir_x, dir_y}, obstacles, {boxes, box_width}, {width, height})
        else
          {box_x, _box_y} = box
          Enum.to_list(0..(box_width - 1))
          |> Enum.all?(fn bx -> is_object_movable?({box_x + bx, ny}, {dir_x, dir_y}, obstacles, {boxes, box_width}, {width, height}) end)
        end
      else
        true
      end
    end
  end

  @spec get_boxes_to_move(non_neg_vector(), vector(), box_list()) :: [non_neg_vector()]
  defp get_boxes_to_move({x, y}, {dir_x, dir_y}, {boxes, box_width}) do
    nx = x + dir_x
    ny = y + dir_y
    box = get_box({nx, ny}, {boxes, box_width})
    if (box === nil) do
      []
    else
      if (dir_x !== 0) do
        [box] ++ get_boxes_to_move({nx + (box_width - 1) * dir_x, ny}, {dir_x, dir_y}, {boxes, box_width})
      else
        {box_x, _box_y} = box
        [box] ++ (Enum.to_list(0..(box_width - 1))
        |> Enum.reduce([], fn x, acc -> acc ++ get_boxes_to_move({box_x + x, ny}, {dir_x, dir_y}, {boxes, box_width}) end))
        |> Enum.uniq()
      end
    end
  end

  defp move_boxes(position, {dir_x, dir_y}, {boxes, box_width}) do
    boxes_to_move = get_boxes_to_move(position, {dir_x, dir_y}, {boxes, box_width})
    next_boxes = boxes_to_move |> Enum.map(fn {x, y} -> {x + dir_x, y + dir_y} end)
    static_boxes = boxes |> Enum.filter(fn {x, y} -> !Enum.member?(boxes_to_move, {x, y}) end)
    {static_boxes ++ next_boxes , box_width}
  end

  @spec get_box_positions_after_robot_moved(non_neg_vector(), [non_neg_vector()], box_list(), non_neg_vector(), [vector()]) :: [non_neg_vector()]
  defp get_box_positions_after_robot_moved({x, y}, obstacles, box_list, dimensions, instructions) do
    if (length(instructions) === 0) do
      {boxes, _box_width} = box_list
      boxes
    else
      {dir_x, dir_y} = hd(instructions)
      if (is_object_movable?({x, y}, {dir_x, dir_y}, obstacles, box_list, dimensions)) do
        next_box_list = move_boxes({x, y}, {dir_x, dir_y}, box_list)
        get_box_positions_after_robot_moved({x + dir_x, y + dir_y}, obstacles, next_box_list, dimensions, tl(instructions))
      else
        get_box_positions_after_robot_moved({x, y}, obstacles, box_list, dimensions, tl(instructions))
      end
    end
  end

  @spec bump_map_line(String.t()) :: String.t()
  defp bump_map_line(map_line) do
    map_line
    |> String.replace(".", "..")
    |> String.replace("#", "##")
    |> String.replace("O", "[]")
    |> String.replace("@", "@.")
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    map = trim_map(lines)
    dimensions = Utils.get_map_dimensions(map)
    instructions = get_instructions(lines)
    obstacles = map |> Utils.get_char_positions_in_map("#")
    boxes = map |> Utils.get_char_positions_in_map("O")
    robot = map |> Utils.get_char_positions_in_map("@") |> hd()

    get_box_positions_after_robot_moved(robot, obstacles, {boxes, 1}, dimensions, instructions)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + (x + 1) + (y + 1) * 100 end)
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    map = trim_map(lines) |> Enum.map(&bump_map_line/1)
    dimensions = Utils.get_map_dimensions(map)
    instructions = get_instructions(lines)
    obstacles = map |> Utils.get_char_positions_in_map("#")
    boxes = map |> Utils.get_char_positions_in_map("[")
    robot = map |> Utils.get_char_positions_in_map("@") |> hd()

    get_box_positions_after_robot_moved(robot, obstacles, {boxes, 2}, dimensions, instructions)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + (x + 2) + (y + 1) * 100 end)
  end
end
