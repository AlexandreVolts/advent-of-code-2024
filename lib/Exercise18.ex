defmodule Exercise18 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}
  @type neighborhood() :: {non_neg_vector(), [non_neg_vector()]}
  @type edge() :: {non_neg_vector(), non_neg_vector()}

  @spec get_corrupted_byte(String.t()) :: non_neg_vector()
  defp get_corrupted_byte(line) do
    values = Regex.scan(~r/\-?\d+/, line) |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
    {hd(values), hd(tl(values))}
  end

  @spec generate_map([non_neg_vector()], non_neg_vector()) :: [non_neg_vector()]
  defp generate_map(corrupted_bytes, {width, height}) do
    0..(width * height)
    |> Enum.map(fn index -> {rem(index, width), div(index, width)} end)
    |> Enum.filter(fn {x, y} -> !(corrupted_bytes |> Enum.member?({x, y})) end)
  end

  @spec get_bytes_around([non_neg_vector()], non_neg_vector()) :: [edge()]
  defp get_bytes_around(non_corrupted_bytes, byte) do
    byte
    |> Utils.get_positions_around()
    |> Enum.filter(fn {x, y} -> non_corrupted_bytes |> Enum.member?({x, y}) end)
    |> Enum.map(fn neighbor -> {byte, neighbor} end)
  end

  @spec build_graph([non_neg_vector()]) :: [edge()]
  defp build_graph(non_corrupted_bytes) do
    non_corrupted_bytes
    |> Enum.map(fn byte -> get_bytes_around(non_corrupted_bytes, byte) end)
    |> Enum.reduce([], fn array, acc -> acc ++ array end)
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    bytes_to_be_read = 1024
    {w, h} = {71, 71}
    edges = lines
    |> Enum.slice(0..(bytes_to_be_read - 1))
    |> Enum.map(&get_corrupted_byte/1)
    |> generate_map({w, h})
    |> build_graph()
    (Graph.new |> Graph.add_edges(edges) |> Graph.dijkstra({0, 0}, {w - 1, h - 1}) |> length()) - 1
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines) do
    0
  end
end
