defmodule Exercise10 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}

  @spec look_around([String.t()], non_neg_vector(), non_neg_integer()) :: [non_neg_vector()]
  defp look_around(lines, position, current) do
    Utils.get_positions_around(position)
    |> Enum.filter(fn {nx, ny} -> Utils.at(lines, nx, ny) !== nil and (Utils.at(lines, nx, ny) |> String.to_integer()) === current + 1 end)
  end

  @spec compute_trailhead_score([String.t()], non_neg_vector()) :: [non_neg_vector()]
  defp compute_trailhead_score(lines, trailhead), do: compute_trailhead_score(lines, trailhead, 0)

  @spec compute_trailhead_score([String.t()], non_neg_vector(), integer()) :: [non_neg_vector()]
  defp compute_trailhead_score(lines, {x, y}, height) do
    if (height === 9) do
      [{x, y}]
    else
      next = look_around(lines, {x, y}, height)
      if (length(next) === 0) do
        []
      else
        next |> Enum.reduce([], fn next_pos, acc -> acc ++ compute_trailhead_score(lines, next_pos, height + 1) end)
      end
    end
  end

  @spec spawn_task_with_uniq_trailhead([String.t()], non_neg_vector()) :: Task.t()
  defp spawn_task_with_uniq_trailhead(lines, trailhead) do
    Task.async(fn -> compute_trailhead_score(lines, trailhead) |> Enum.uniq() |> length() end)
  end

  @spec spawn_task_with_trailhead_rating([String.t()], non_neg_vector()) :: Task.t()
  defp spawn_task_with_trailhead_rating(lines, trailhead) do
    Task.async(fn -> compute_trailhead_score(lines, trailhead) |> length() end)
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    lines
    |> Utils.get_char_positions_in_map("0")
    |> Enum.map(fn trailhead -> spawn_task_with_uniq_trailhead(lines, trailhead) end)
    |> Task.await_many()
    |> Enum.sum()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    lines
    |> Utils.get_char_positions_in_map("0")
    |> Enum.map(fn trailhead -> spawn_task_with_trailhead_rating(lines, trailhead) end)
    |> Task.await_many()
    |> Enum.sum()
  end
end
