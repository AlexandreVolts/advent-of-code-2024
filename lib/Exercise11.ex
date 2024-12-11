defmodule Exercise11 do
  require Integer

  @spec slice_stone(String.t()) :: {non_neg_integer(), non_neg_integer()}
  defp slice_stone(stone) do
    len = String.length(stone)
    {
      (stone |> String.slice(0, div(len, 2)) |> String.to_integer()),
      (stone |> String.slice(div(-len, 2), len) |> String.to_integer())
    }
  end

  @spec blink(non_neg_integer(), integer(), non_neg_integer()) :: non_neg_integer()
  defp blink(stone, depth, multiplier) do
    if (depth <= 0) do
      1
    else
      if (stone === 0) do
        blink(multiplier, depth - 2, multiplier)
      else
        if (String.length("#{stone}") |> Integer.is_even()) do
          {left_stone, right_stone} = slice_stone("#{stone}")
          blink(left_stone, depth - 1, multiplier) + blink(right_stone, depth - 1, multiplier)
        else
          blink(stone * multiplier, depth - 1, multiplier)
        end
      end
    end
  end

  @spec spawn_task(non_neg_integer(), integer(), non_neg_integer()) :: Task.t()
  defp spawn_task(stone, depth, multiplier) do
    Task.async(fn -> blink(stone, depth, multiplier)  end)
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    hd(lines)
    |> Utils.str_to_integer_list()
    |> Enum.map(fn x -> spawn_task(x, 25, 2024) end)
    |> Task.await_many()
    |> Enum.sum()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    hd(lines)
    |> Utils.str_to_integer_list()
    #|> Enum.map(fn x -> spawn_task(x, 75, 2024) end)
    #|> Task.await_many()
    |> Enum.sum()
  end
end
