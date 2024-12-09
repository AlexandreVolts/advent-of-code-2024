defmodule Utils do
  @spec pop(list(any())) :: list(any())
  def pop(list) do
    if (length(list) === 0) do
      []
    else
      list |> Enum.reverse() |> tl() |> Enum.reverse()
    end
  end
end
