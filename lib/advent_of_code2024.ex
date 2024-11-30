defmodule AdventOfCode2024 do
  use Application
  def read_file(file_name) do
      {:ok, file} = File.open(file_name, [:read])
      content = IO.read(file, :line)
      File.close(file)

      content
  end

  def start(_type, _args) do
    IO.puts(AdventOfCode2024.read_file("assets/1.txt"))
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
