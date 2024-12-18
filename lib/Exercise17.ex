defmodule Exercise17 do
  import Bitwise

  @type program :: [non_neg_integer()]
  @type registers :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}
  @type instruction_output :: {non_neg_integer(), registers(), non_neg_integer()}

  @spec get_register(String.t()) :: non_neg_integer()
  defp get_register(line), do: Regex.scan(~r/\d+/, line) |> hd() |> hd() |> String.to_integer()

  @spec get_program(String.t()) :: program()
  defp get_program(line) do
    line |> String.split(": ") |> tl() |> hd() |> Utils.str_to_integer_list(",")
  end

  @spec get_combo_operand(non_neg_integer(), registers()) :: non_neg_integer()
  defp get_combo_operand(operand, {ra, rb, rc}) do
    case operand do
      4 -> ra
      5 -> rb
      6 -> rc
      _ -> operand
    end
  end

  @spec adv(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp adv(operand, {ra, rb, rc}, pointer) do
    output = div(ra, 2 ** get_combo_operand(operand, {ra, rb, rc}))
    {output, {output, rb, rc}, pointer + 2}
  end

  @spec bxl(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp bxl(operand, {ra, rb, rc}, pointer) do
    {bxor(rb, operand), {ra, bxor(rb, operand), rc}, pointer + 2}
  end

  @spec bst(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp bst(operand, {ra, rb, rc}, pointer) do
    output = rem(get_combo_operand(operand, {ra, rb, rc}), 8)
    {output, {ra, output, rc}, pointer + 2}
  end

  @spec jnz(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp jnz(operand, {ra, rb, rc}, pointer) do
    {0, {ra, rb, rc}, if ra === 0 do pointer + 2 else operand end}
  end

  @spec bxc(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp bxc(_operand, {ra, rb, rc}, pointer), do: {bxor(rb, rc), {ra, bxor(rb, rc), rc}, pointer + 2}

  @spec out(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp out(operand, registers, pointer) do
    {rem(get_combo_operand(operand, registers), 8), registers, pointer + 2}
  end

  @spec bdv(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp bdv(operand, {ra, rb, rc}, pointer) do
    output = div(ra, 2 ** get_combo_operand(operand, {ra, rb, rc}))
    {output, {ra, output, rc}, pointer + 2}
  end

  @spec cdv(non_neg_integer(), registers(), non_neg_integer()) :: instruction_output()
  defp cdv(operand, {ra, rb, rc}, pointer) do
    output = div(ra, 2 ** get_combo_operand(operand, {ra, rb, rc}))
    {output, {ra, rb, output}, pointer + 2}
  end

  @spec run_program(program(), registers()) :: String.t()
  defp run_program(program, registers), do: run_program(program, registers, 0)

  @spec run_program(program(), registers(), non_neg_integer()) :: String.t()
  defp run_program(program, registers, pointer) do
    instructions = [&adv/3, &bxl/3, &bst/3, &jnz/3, &bxc/3, &out/3, &bdv/3, &cdv/3]
    instruction_index = program |> Enum.at(pointer)
    operand = program |> Enum.at(pointer + 1)
    if (instruction_index === nil or operand === nil) do
      ""
    else
      instruction = instructions |> Enum.at(instruction_index)
      {output, nxt_registers, nxt_pointer} = instruction.(operand, registers, pointer)
      if (instruction_index === 5) do Integer.to_string(output) else "" end <> run_program(program, nxt_registers, nxt_pointer)
    end
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
     ra = get_register(hd(lines))
     rb = get_register(hd(tl(lines)))
     rc = get_register(hd(tl(tl(lines))))
     lines
     |> Enum.reverse()
     |> hd()
     |> get_program()
     |> run_program({ra, rb, rc})
  end

  @spec ex2([String.t()]) :: non_neg_integer()
  def ex2(_lines), do: 0
end
