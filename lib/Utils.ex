defmodule Utils do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}

  @spec at([String.t()], integer(), integer()) :: String.t() | nil
  def at(lines, x, y) do
    if (Utils.is_outside?(lines, x, y)) do
      nil
    else
      lines |> Enum.at(y) |> String.at(x)
    end
  end

  @spec get_positions_around(non_neg_vector()) :: [non_neg_vector()]
  def get_positions_around({x, y}) do
    0..3
    |> Enum.map(fn index -> index * (:math.pi / 2) end)
    |> Enum.map(fn angle -> {round(x + :math.cos(angle)), round(y + :math.sin(angle))} end)
  end

  @spec get_map_dimensions([String.t()]) :: non_neg_vector()
  def get_map_dimensions(lines), do: {hd(lines) |> String.length(), length(lines)}

  @spec str_to_integer_list([String.t()], String.t()) :: [integer()]
  def str_to_integer_list(str, separator \\ " ") do
    str |> String.split(separator, trim: true) |> Enum.map(&String.to_integer/1)
  end

  @spec pop(list(any())) :: list(any())
  def pop(list) do
    if (length(list) === 0) do
      []
    else
      list |> Enum.reverse() |> tl() |> Enum.reverse()
    end
  end

  @spec is_outside?(list(String.t()), integer(), integer()) :: boolean()
  def is_outside?(lines, x, y) do
    x < 0 or y < 0 or y >= length(lines) or x >= Enum.at(lines, y) |> String.length()
  end

  @spec get_char_positions_in_map([String.t()], String.t()) :: [non_neg_vector()]
  def get_char_positions_in_map(lines, char) do
    width = hd(lines) |> String.length()
    lines
    |> Enum.join()
    |> String.split(char)
    |> Enum.reduce([-1], fn cur, acc -> acc ++ [hd(Enum.take(acc, -1)) + String.length(cur) + 1] end)
    |> tl() |> Enum.reverse() |> tl() |> Enum.reverse()
    |> Enum.map(fn index -> {rem(index, width), div(index, width)} end)
  end
end
