defmodule AdventOfCode2024 do
  use Application
  def read_file(file_name) do
      {:ok, file} = File.open(file_name, [:read])
      content = IO.read(file, :eof)
      File.close(file)

      String.split(content, "\n")
  end

  def run_function({func, index}) do
    output = AdventOfCode2024.read_file("assets/#{div(index, 2)}.txt") |> func.()
    IO.puts("Exercise #{div(index, 2)}-#{rem(index, 2) + 1}: #{output}")
  end

  @spec main([non_neg_integer()]) :: :ok
  def main(exercises) do
    functions = [
      &Exercise0.ex1/1, &Exercise0.ex2/1,
      &Exercise1.ex1/1, &Exercise1.ex2/1,
      &Exercise2.ex1/1, &Exercise2.ex2/1,
      &Exercise3.ex1/1, &Exercise3.ex2/1,
      &Exercise4.ex1/1, &Exercise4.ex2/1,
      &Exercise5.ex1/1, &Exercise5.ex2/1,
      &Exercise6.ex1/1, &Exercise6.ex2/1,
      &Exercise7.ex1/1, &Exercise7.ex2/1,
      &Exercise8.ex1/1, &Exercise8.ex2/1,
      &Exercise9.ex1/1, &Exercise9.ex2/1,
      &Exercise10.ex1/1, &Exercise10.ex2/1,
      &Exercise11.ex1/1, &Exercise11.ex2/1,
      &Exercise12.ex1/1, &Exercise12.ex2/1,
      &Exercise13.ex1/1, &Exercise13.ex2/1,
      &Exercise14.ex1/1, &Exercise14.ex2/1,
      &Exercise15.ex1/1, &Exercise15.ex2/1,
      &Exercise16.ex1/1, &Exercise16.ex2/1,
      &Exercise17.ex1/1, &Exercise17.ex2/1,
      &Exercise18.ex1/1, &Exercise18.ex2/1,
      &Exercise19.ex1/1, &Exercise19.ex2/1
    ]
    functions
    |> Enum.with_index()
    |> Enum.filter(fn {_func, index} -> length(exercises) === 0 or Enum.member?(exercises, div(index, 2)) end)
    |> Enum.each(&AdventOfCode2024.run_function/1)
  end

  defp parse_args(args) do
    {opts, word, _} = args |> OptionParser.parse(switches: [exercises: :boolean])
    if (!opts[:exercises]) do
      []
    else
      hd(word)
      |> String.replace(" ", "")
      |> String.split(",")
      |> Enum.map(fn pair -> pair |> Utils.str_to_integer_list("-") end)
      |> Enum.map(fn pair -> if (length(pair) === 2) do Enum.to_list(hd(pair)..(hd(tl(pair)))) else pair end end)
      |> Enum.reduce([], fn array, acc -> acc ++ array end)
    end
  end

  def start(_type, args) do
    parse_args(args) |> main()
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
