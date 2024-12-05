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

  @spec main() :: :ok
  def main() do
    functions = [
      &Exercise0.ex1/1, &Exercise0.ex2/1,
      &Exercise1.ex1/1, &Exercise1.ex2/1,
      &Exercise2.ex1/1, &Exercise2.ex2/1,
      &Exercise3.ex1/1, &Exercise3.ex2/1,
      &Exercise4.ex1/1, &Exercise4.ex2/1,
      &Exercise5.ex1/1, &Exercise5.ex2/1
    ]
    functions |> Enum.with_index() |> Enum.each(&AdventOfCode2024.run_function/1)
  end

  def start(_type, _args) do
    main()
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
