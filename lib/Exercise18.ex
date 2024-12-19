defmodule Exercise18 do
  @type non_neg_vector() :: {non_neg_integer(), non_neg_integer()}
  @type neighborhood() :: {non_neg_vector(), [non_neg_vector()]}
  @type edge() :: {non_neg_vector(), non_neg_vector()}
  @type clusters() :: [[non_neg_vector()]]

  @spec get_corrupted_byte(String.t()) :: non_neg_vector()
  defp get_corrupted_byte(line) do
    values = Regex.scan(~r/\-?\d+/, line) |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
    {hd(values), hd(tl(values))}
  end

  @spec generate_map([non_neg_vector()], non_neg_integer()) :: [non_neg_vector()]
  defp generate_map(corrupted_bytes, size) do
    0..(size * size)
    |> Enum.map(fn index -> {rem(index, size), div(index, size)} end)
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

  @spec get_positions_around([non_neg_vector()], non_neg_vector()) :: [non_neg_vector()]
  defp get_positions_around(corrupted_bytes, {x, y}) do
    corrupted_bytes
    |> List.delete({x, y})
    |> Enum.filter(fn {nx, ny} -> nx <= x + 1 and nx >= x - 1 and ny <= y + 1 and ny >= y - 1 end)
  end

  @spec exclude_from_corrupted_bytes([non_neg_vector()], [non_neg_vector()]) :: [non_neg_vector()]
  defp exclude_from_corrupted_bytes(corrupted_bytes, purrified) do
    corrupted_bytes |> Enum.filter(fn {nx, ny} -> !(purrified |> Enum.member?({nx, ny})) end)
  end

  @spec get_cluster([non_neg_vector()], non_neg_vector()) :: [non_neg_vector()]
  defp get_cluster(corrupted_bytes, {x, y}) do
      neighbors = get_positions_around(corrupted_bytes, {x, y})
      if (length(neighbors) === 0) do
        [{x, y}]
      else
        next_corrupted_bytes = corrupted_bytes |> exclude_from_corrupted_bytes(neighbors ++ [{x, y}])
        neighbors ++ Enum.reduce(neighbors, [], fn {nx, ny}, acc -> acc ++ get_cluster(next_corrupted_bytes, {nx, ny}) end)
      end
  end

  @spec clusterize_corrupted_bytes([non_neg_vector()]) :: clusters()
  defp clusterize_corrupted_bytes(corrupted_bytes) do
    if (length(corrupted_bytes) === 0) do
      []
    else
      cluster = [hd(corrupted_bytes)] ++ get_cluster(tl(corrupted_bytes), hd(corrupted_bytes)) |> Enum.uniq()
      next_corrupted_bytes = corrupted_bytes |> exclude_from_corrupted_bytes(cluster)
      [cluster] ++ clusterize_corrupted_bytes(next_corrupted_bytes)
    end
  end

  @spec is_connected_to_cluster?([non_neg_vector()], non_neg_vector()) :: boolean()
  defp is_connected_to_cluster?(cluster, byte), do: get_positions_around(cluster, byte) |> length() !== 0

  @spec is_intersecting?(non_neg_vector(), non_neg_vector(), non_neg_vector()) :: boolean()
  defp is_intersecting?({x1, y1}, {x2, y2}, {x3, y3}), do: (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)

  @spec is_pair_blocking?(non_neg_vector(), non_neg_vector(), non_neg_integer()) :: boolean()
  defp is_pair_blocking?(p1, p2, size) do
    p3 = {0, 0}
    p4 = {size, size}
    (is_intersecting?(p1, p3, p4) !== is_intersecting?(p2, p3, p4) and
    is_intersecting?(p1, p2, p3) !== is_intersecting?(p1, p2, p4))
  end

  @spec is_blocking_side_bytes?([non_neg_vector()], non_neg_integer()) :: boolean()
  defp is_blocking_side_bytes?(side_bytes, size) do
    if (length(side_bytes) <= 1) do
      false
    else
      byte = hd(side_bytes)
      next_bytes = tl(side_bytes)
      matching_bytes = next_bytes |> Enum.filter(fn b -> is_pair_blocking?(byte, b, size) end) |> length()
      if (matching_bytes > 0) do true else is_blocking_side_bytes?(next_bytes, size) end
    end
  end

  @spec compute_blocking_byte(clusters(), [non_neg_vector()], non_neg_integer()) :: non_neg_vector()
  defp compute_blocking_byte(clusters, remaining_bytes, size) do
    if (length(remaining_bytes) === 1) do
      hd(remaining_bytes)
    else
      byte = hd(remaining_bytes)
      non_linked_clusters = clusters |> Enum.filter(fn cluster -> !is_connected_to_cluster?(cluster, byte) end)
      linked_clusters = clusters |> Enum.filter(fn cluster -> is_connected_to_cluster?(cluster, byte) end)
      merged_cluster = (linked_clusters ++ [[byte]]) |> Enum.reduce([], fn array, acc -> acc ++ array end)
      side_bytes = merged_cluster |> Enum.filter(fn {x, y} -> x === 0 or y === 0 or x === size - 1 or y === size - 1 end)
      if (is_blocking_side_bytes?(side_bytes, size)) do
        byte
      else
        new_clusters = non_linked_clusters ++ [merged_cluster]
        compute_blocking_byte(new_clusters, tl(remaining_bytes), size)
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    bytes_to_be_read = 1024
    size = 71
    edges = lines
    |> Enum.slice(0..(bytes_to_be_read - 1))
    |> Enum.map(&get_corrupted_byte/1)
    |> generate_map(size)
    |> build_graph()
    (Graph.new |> Graph.add_edges(edges) |> Graph.dijkstra({0, 0}, {size - 1, size - 1}) |> length()) - 1
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    min_bytes_to_be_read = 1024
    size = 71
    bytes = lines |> Enum.map(&get_corrupted_byte/1)
    clusters = bytes |> Enum.slice(0..(min_bytes_to_be_read - 1)) |> clusterize_corrupted_bytes()
    remaining_bytes = bytes |> Enum.slice((min_bytes_to_be_read)..length(bytes))
    {x, y} = compute_blocking_byte(clusters, remaining_bytes, size)
    "#{x}#{y}" |> String.to_integer()
  end
end
