defmodule Exercise9 do
  require Integer

  @type disk_chunk :: list(non_neg_integer())
  @type disk :: {disk_chunk(), disk_chunk()}

  @spec str_to_integer_list(String.t()) :: list(non_neg_integer())
  defp str_to_integer_list(str), do: str |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)

  @spec uncompress_disk(list(non_neg_integer())) :: disk()
  defp uncompress_disk(compressed_disk) do
    cond do
      (length(compressed_disk) === 0) -> {[], []}
      (length(compressed_disk) === 1) -> {[hd(compressed_disk)], []}
      true ->
        {disk_data, free} = uncompress_disk(tl(tl(compressed_disk)))
        {[hd(compressed_disk)] ++ disk_data, [hd(tl(compressed_disk))] ++ free}
    end
  end

  @spec uncompress_disk_data(disk_chunk()) :: disk_chunk()
  defp uncompress_disk_data(disk_data), do: uncompress_disk_data(disk_data, 0)

  @spec uncompress_disk_data(disk_chunk(), non_neg_integer()) :: disk_chunk()
  defp uncompress_disk_data(disk_data, index) do
    if (length(disk_data) === 0) do
      []
    else
      List.duplicate(index, hd(disk_data)) ++ uncompress_disk_data(tl(disk_data), index + 1)
    end
  end

  @spec get_chunk_by_data_type(disk_chunk(), non_neg_integer()) :: [non_neg_integer()]
  defp get_chunk_by_data_type(disk_data, data_type) do
    if (length(disk_data) === 0 or hd(disk_data) !== data_type) do
      []
    else
      [hd(disk_data)] ++ get_chunk_by_data_type(tl(disk_data), data_type)
    end
  end

  @spec compute_chunk_checksum(disk_chunk(), non_neg_integer()) :: non_neg_integer()
  defp compute_chunk_checksum(disk_data, start_index) do
    disk_data |> Enum.with_index() |> Enum.reduce(0, fn {x, index}, acc -> acc + x * (start_index + index) end)
  end

  @spec get_checksum(disk()) :: non_neg_integer()
  defp get_checksum(disk), do: get_checksum(disk, 0)

  @spec get_checksum(disk(), non_neg_integer()) :: non_neg_integer()
  defp get_checksum({disk_data, free}, index) do
    if (length(disk_data) === 0) do
      0
    else
      if (length(free) === 0) do
        compute_chunk_checksum(disk_data, index)
      else
        chunk = get_chunk_by_data_type(disk_data, hd(disk_data))
        disk_data_checksum = compute_chunk_checksum(chunk, index)
        free_chunk = disk_data |> Enum.slice(length(chunk), length(disk_data)) |> Enum.slice(-hd(free), hd(free))
        free_checksum = compute_chunk_checksum(Enum.reverse(free_chunk), index + length(chunk))
        data_removed_count = length(chunk) + hd(free)
        if (length(disk_data) - data_removed_count <= 0) do
          free_checksum + disk_data_checksum
        else
          new_disk_data = Enum.slice(disk_data, length(chunk), length(disk_data) - data_removed_count)
          free_checksum + disk_data_checksum + get_checksum({new_disk_data, tl(free)}, index + data_removed_count)
        end
      end
    end
  end

  @spec get_start_index(disk(), non_neg_integer()) :: non_neg_integer()
  defp get_start_index({disk_data, free}, chunk_size) do
    disk_data_chunk = disk_data |> Enum.slice(0, chunk_size)
    free_chunk = free |> Enum.slice(0, chunk_size - 1)
    (disk_data_chunk ++ free_chunk) |> Enum.sum()
  end

  @spec get_start_index(disk()) :: non_neg_integer()
  defp get_start_index({disk_data, free}) do
    disk_data_chunk = disk_data |> Enum.slice(0, length(disk_data) - 1)
    free_chunk = free |> Enum.slice(0, length(disk_data) - 1)
    (disk_data_chunk ++ free_chunk) |> Enum.sum()
  end

  @spec update_free_space(disk_chunk(), non_neg_integer(), non_neg_integer()) :: disk_chunk()
  defp update_free_space(free, index, value) do
    free |> Enum.with_index() |> Enum.map(fn {x, i} -> if i === index do x - value else x end end)
  end

  @spec get_checksum_moving_files(disk()) :: non_neg_integer()
  defp get_checksum_moving_files({disk_data, free}), do: get_checksum_moving_files({disk_data, free}, free)

  @spec get_checksum_moving_files(disk(), disk_chunk()) :: non_neg_integer()
  defp get_checksum_moving_files({disk_data, free}, default_free) do
    if (length(disk_data) === 0) do
      0
    else
      last_item = disk_data |> Enum.reverse() |> hd()
      free_space_index = free |> Enum.find_index(fn free_space -> free_space >= last_item end)
      uncompressed_chunk = List.duplicate(length(disk_data) - 1, last_item)
      nxt_disk_data = disk_data |> Utils.pop()
      if (free_space_index === nil or free_space_index >= length(disk_data)) do
        start_index = get_start_index({disk_data, default_free})
        output = compute_chunk_checksum(uncompressed_chunk, start_index)
        output + get_checksum_moving_files({nxt_disk_data, free}, default_free)
      else
        diff = (default_free |> Enum.at(free_space_index)) - (free |> Enum.at(free_space_index))
        start_index = get_start_index({disk_data, default_free}, free_space_index + 1) + diff
        nxt_free = update_free_space(free, free_space_index, length(uncompressed_chunk))
        output = compute_chunk_checksum(uncompressed_chunk, start_index)
        output + get_checksum_moving_files({nxt_disk_data, nxt_free}, default_free)
      end
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    {disk_data, free} = hd(lines) |> str_to_integer_list() |> uncompress_disk()
    get_checksum({disk_data |> uncompress_disk_data(), free})
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    {disk_data, free} = hd(lines) |> str_to_integer_list() |> uncompress_disk()
    get_checksum_moving_files({disk_data, free})
  end
end
