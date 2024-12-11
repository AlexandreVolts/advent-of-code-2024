# AdventOfCode2024

My advent of code 2024 in Elixir.

## Commands

- `mix deps.get` - install required dependencies
- `mix run` - run the program

## Configuration

If you want to run specific exercises, I got too bored to configure the app, so you can directly edit the `mix.exs` file.

On the line `mod: {AdventOfCode2024, ["--exercises", "1-25"]}`, you can replace the "1-25" with strings of the following format: `"1-4, 6, 9,10-12"` where `-` indicates the interval between two numbers and `,` the separation between two intervals.