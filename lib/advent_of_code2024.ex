defmodule AdventOfCode2024 do
  use Application
  def read_file(file_name) do
      {:ok, file} = File.open(file_name, [:read])
      content = IO.read(file, :eof)
      File.close(file)

      String.split(content, "\n")
  end

  def main() do
    AdventOfCode2024.read_file("assets/0.txt") |> Exercise_0.ex1() |> IO.puts()
    AdventOfCode2024.read_file("assets/0.txt") |> Exercise_0.ex2() |> IO.puts()
  end
  def start(_type, _args) do
    main()
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
