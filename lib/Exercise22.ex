defmodule Exercise22 do
  import Bitwise

  @type instruction :: {function(), integer()}
  @type pair() :: {integer(), non_neg_integer()}
  @type key() :: {integer(), integer(), integer(), integer()}
  @type key_with_value() :: {{integer() | :infinity, integer() | :infinity, integer() | :infinity, integer() | :infinity}, integer()}

  @spec encode(integer(), [instruction()], non_neg_integer()) :: integer()
  defp encode(x, instructions, prune) do
    if (length(instructions) === 0) do
      x
    else
      {func, y} = hd(instructions)
      bxor(func.(x, y), x) |> rem(prune) |> encode(tl(instructions), prune)
    end
  end

  @spec encode_x_times(integer(), [instruction()], non_neg_integer(), non_neg_integer()) :: integer()
  defp encode_x_times(x, instructions, prune, times) do
    if (times === 0) do
      x
    else
      encode(x, instructions, prune) |> encode_x_times(instructions, prune, times - 1)
    end
  end

  @spec compute_hash(integer(), [instruction()], non_neg_integer(), integer(), key(), [key()]) :: [key_with_value()]
  defp compute_hash(x, instructions, prune, times) do
    compute_hash(x, instructions, prune, times, {:infinity, :infinity, :infinity, :infinity}, [])
  end

  @spec compute_hash(integer(), [instruction()], non_neg_integer(), non_neg_integer(), key(), [key()]) :: [key_with_value()]
  defp compute_hash(x, instructions, prune, times, {k1, k2, k3, k4}, seen_keys) do
    if (times === 0) do
      []
    else
      y = encode(x, instructions, prune)
      k5 = rem(y, 10) - rem(x, 10)
      if (k1 === :infinity or Enum.member?(seen_keys, {k1, k2, k3, k4})) do
        compute_hash(y, instructions, prune, times - 1, {k2, k3, k4, k5}, seen_keys)
      else
        [{{k1, k2, k3, k4}, rem(x, 10)}] ++ compute_hash(y, instructions, prune, times - 1, {k2, k3, k4, k5}, seen_keys ++ [{k1, k2, k3, k4}])
      end
    end
  end

  @spec merge_identical_keys([key_with_value()], key()) :: key_with_value()
  defp merge_identical_keys(keys_with_values, key) do
    value = keys_with_values
    |> Enum.filter(fn {k, _value} -> key === k end)
    |> Enum.reduce(0, fn {_key, v}, acc -> acc + v end)
    {key, value}
  end

  @spec merge_keys([key_with_value()]) :: [non_neg_integer()]
  defp merge_keys(keys_with_values) do
    if (length(keys_with_values) === 0) do
      []
    else
      {key, _value} = hd(keys_with_values)
      {_key, value} = merge_identical_keys(keys_with_values, key)
      IO.inspect(key)
      [value] ++ merge_keys(keys_with_values |> Enum.filter(fn {k, _value} -> key !== k end))
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    instructions = [{&*/2, 64}, {&div/2, 32}, {&*/2, 2048}]
    lines
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn x -> encode_x_times(x, instructions, 16777216, 2000) end)
    |> Enum.sum()
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(lines) do
    instructions = [{&*/2, 64}, {&div/2, 32}, {&*/2, 2048}]
    lines
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn x -> Task.async(fn -> compute_hash(x, instructions, 16777216, 2000) end) end)
    |> Task.await_many()
    |> Enum.reduce([], fn array, acc -> array ++ acc end)
    |> merge_keys()
    |> Enum.max()
  end
end
