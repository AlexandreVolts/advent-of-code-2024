defmodule Exercise23 do
  @type link() :: {String.t(), String.t()}

  @spec get_links([String.t()]) :: [link()]
  defp get_links(lines) do
    lines
    |> Enum.map(fn line -> String.split(line, "-") end)
    |> Enum.map(fn pair -> {hd(pair), hd(tl(pair))} end)
  end

  @spec get_associated_nodes([link()], String.t()) :: [String.t()]
  defp get_associated_nodes(links, node) do
    links
    |> Enum.filter(fn {a, b} -> a === node or b == node end)
    |> Enum.reduce([], fn {a, b}, acc -> acc ++ [if a === node do b else a end] end)
  end

  @spec build_graph([link()]) :: map()
  defp build_graph(links) do
    if (length(links) === 0) do
      Map.new()
    else
      {left, right} = hd(links)
      graph = build_graph(tl(links))
      {_cur, graph1} = graph |> Map.get_and_update(left, fn cur -> {cur, (if (cur === nil) do [] else cur end ++ get_associated_nodes(links, left)) |> Enum.uniq()} end)
      {_cur2, output} = graph1 |> Map.get_and_update(right, fn cur -> {cur, (if (cur === nil) do [] else cur end ++ get_associated_nodes(links, right)) |> Enum.uniq()} end)
      output
    end
  end

  @spec get_circular_link(map(), String.t(), non_neg_integer()) :: [[String.t()]]
  defp get_circular_link(graph, cur, depth), do: get_circular_link(graph, cur, [], depth)

  @spec get_circular_link(map(), String.t(), [String.t()], non_neg_integer()) :: [[String.t()]]
  defp get_circular_link(graph, cur, chain, depth) do
    if (graph |> Map.get(cur) === nil or depth === 0) do
      if (depth === 0 and cur === hd(chain |> Enum.reverse())) do
        [chain]
      else
        []
      end
    else
      graph
      |> Map.get(cur)
      |> Enum.reduce([], fn next, acc -> acc ++ get_circular_link(graph |> Map.delete(cur), next, [cur] ++ chain, depth - 1) end)
    end
  end

  @spec get_circular_links(map(), non_neg_integer()) :: [[String.t()]]
  defp get_circular_links(graph, depth) do
    keys = graph |> Map.keys()
    if (length(keys) === 0) do
      []
    else
      get_circular_link(graph, hd(keys), depth)
      ++ get_circular_links(graph |> Map.delete(hd(keys)), depth)
    end
  end

  @spec get_nodes_with_letter([[String.t()]], String.t()) :: non_neg_integer()
  defp get_nodes_with_letter(links, letter) do
    links |> Enum.count(fn la -> la |> Enum.map(fn lb -> String.at(lb, 0) end) |> Enum.join() |> String.contains?(letter) end)
  end

  @spec find_master_node([String.t()]) :: String.t()
  defp find_master_node(merged_links) do
    {node, _size} = merged_links
    |> Enum.uniq()
    |> Enum.map(fn la -> {la, Enum.count(merged_links, fn lb -> la === lb end)} end)
    |> Enum.sort_by(fn {_node, connections} -> connections end, :desc)
    |> hd()
    node
  end

  @spec get_password([[String.t()]], String.t()) :: String.t()
  defp get_password(links, master_node) do
    links
    |> Enum.filter(fn x -> x |> Enum.reverse() |> hd() === master_node end)
    |> Enum.reduce([], fn array, acc -> array ++ acc end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.join(",")
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    get_links(lines)
    |> build_graph()
    |> get_circular_links(3)
    |> get_nodes_with_letter("t")
    |> div(2)
  end

  @spec ex2([String.t()]) :: String.t()
  def ex2(lines) do
    links = get_links(lines)
    |> build_graph()
    |> get_circular_links(3)

    master_node = links |> Enum.map(fn x -> x |> Enum.reverse() |> hd() end) |> find_master_node()
    get_password(links, master_node)
  end
end
