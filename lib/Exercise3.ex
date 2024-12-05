defmodule Exercise3 do
  @spec strmul_to_integer(String.t()) :: integer()
  defp strmul_to_integer(multiplication) do
    values = Regex.scan(~r/[0-9]{1,3}/, multiplication)
            |> Enum.map(fn array -> hd(array) |> String.to_integer() end)
    hd(values) * (values |> tl() |> hd())
  end

  @spec get_mul(String.t()) :: integer()
  defp get_mul(line) do
    Regex.scan(~r/mul\(([0-9]{1,3}),([0-9]{1,3})\)/, line)
    |> Enum.map(fn array -> hd(array) |> strmul_to_integer() end)
    |> Enum.sum()
  end

  @spec remove_disable_parts(String.t()) :: String.t()
  defp remove_disable_parts(line) do
    disabled = "don't()"
    enabled = "do()"
    chunks = line |> String.split(disabled, trim: true)

    [hd(chunks)] ++ (tl(chunks) |> Enum.map(fn str -> str |> String.split(enabled) |> tl() |> Enum.join("") end))
    |> Enum.join("")
  end

  @spec ex1(list(String.t())) :: non_neg_integer()
  def ex1(lines), do: lines |> Enum.join() |> get_mul()

  @spec ex2(list(String.t())) :: non_neg_integer()
  def ex2(lines), do: lines |> Enum.join() |> remove_disable_parts() |> get_mul()
end
