defmodule Exercise24 do
  @type wire :: [String.t()]

  @spec integer_to_output_variable_name(non_neg_integer()) :: String.t()
  defp integer_to_output_variable_name(value), do: "z#{String.pad_leading("#{value}", 2, "0")}"

  @spec init_system([[String.t()]]) :: map()
  defp init_system(variables) do
    if (length(variables) === 0) do
      Map.new()
    else
      output = init_system(tl(variables))
      variable_name = hd(hd(variables))
      variable_value = hd(tl(hd(variables)))
      Map.put(output, variable_name, variable_value === "1")
    end
  end

  @spec find_executable_instruction(map(), [wire()]) :: wire() | nil
  defp find_executable_instruction(system, instructions) do
    instructions |> Enum.find(fn instruction -> Map.has_key?(system, Enum.at(instruction, 0)) and Map.has_key?(system, Enum.at(instruction, 2)) end)
  end

  @spec execute_instruction(map(), wire()) :: map()
  defp execute_instruction(system, instruction) do
    key = instruction |> Enum.at(3)
    gate_name = instruction |> Enum.at(1)
    x = system |> Map.get(instruction |> Enum.at(0))
    y = system |> Map.get(instruction |> Enum.at(2))
    gate = %{"AND" => &and/2, "OR" => &or/2, "XOR" => &(&1 !== &2)} |> Map.get(gate_name)
    system |> Map.put(key, gate.(x, y))
  end

  @spec execute_system(map(), [wire()]) :: map()
  defp execute_system(system, instructions) do
    instruction = find_executable_instruction(system, instructions)
    if (instruction === nil) do
      system
    else
      next_system = execute_instruction(system, instruction)
      next_instruction = instructions |> List.delete(instruction)
      execute_system(next_system, next_instruction)
    end
  end

  @spec get_binary_number(map()) :: String.t()
  defp get_binary_number(system), do: get_binary_number(system, 0)

  @spec get_binary_number(map(), non_neg_integer()) :: String.t()
  defp get_binary_number(system, index) do
    cur = system |> Map.get(integer_to_output_variable_name(index))
    if (cur === nil) do "" else get_binary_number(system, index + 1) <> (if cur do "1" else "0" end)  end
  end

  @spec find_wire_by_output([wire()], String.t()) :: wire() | nil
  defp find_wire_by_output(wires, output), do: wires |> Enum.find(fn wire -> Enum.at(wire, 3) === output end)

  @spec find_parent_wire_by_gate([wire()], wire(), String.t()) :: wire() | nil
  defp find_parent_wire_by_gate(wires, wire, gate) do
    wires |> Enum.find(fn w -> (Enum.at(w, 3) === Enum.at(wire, 2) and Enum.at(w, 1) === gate) or (Enum.at(w, 3) === Enum.at(wire, 0) and Enum.at(w, 1) === gate) end)
  end

  @spec find_parents_wire([wire()], wire()) :: wire() | nil
  defp find_parents_wire(wires, wire) do
    wires |> Enum.filter(fn w -> Enum.at(w, 3) === Enum.at(wire, 2) or Enum.at(w, 3) === Enum.at(wire, 0) end)
  end

  @spec get_full_adder_issues([wire()], non_neg_integer()) :: [String.t()]
  defp get_full_adder_issues(wires, index) do
    my_xor = find_wire_by_output(wires, integer_to_output_variable_name(index))

    if (my_xor |> Enum.at(1) !== "XOR") do
      [integer_to_output_variable_name(index)]
    else
      parent_wires = find_parents_wire(wires, my_xor)
      my_or = find_parent_wire_by_gate(parent_wires, my_xor, "OR")
      my_second_xor = find_parent_wire_by_gate(parent_wires, my_xor, "XOR")
      if (my_or === nil) do
        [parent_wires |> Enum.filter(fn wire -> wire !== my_second_xor end) |> hd() |> Enum.at(3)]
      else
        if (my_second_xor === nil) do
          [parent_wires |> Enum.filter(fn wire -> wire !== my_or end) |> hd() |> Enum.at(3)]
        else
          find_parents_wire(wires, my_or)
          |> Enum.filter(fn wire -> wire |> Enum.at(1) !== "AND" end)
          |> Enum.map(fn wire -> wire |> Enum.at(3) end)
        end
      end
    end
  end

  @spec find_wires_to_be_swapped([wire()], non_neg_integer()) :: [String.t()]
  defp find_wires_to_be_swapped(wires, max) do
    2..max |> Enum.reduce([], fn x, acc -> acc ++ get_full_adder_issues(wires, x) end)
  end

  @spec ex1([String.t()]) :: non_neg_integer()
  def ex1(lines) do
    system = lines
    |> Enum.filter(fn line -> String.contains?(line, ":") end)
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> init_system()

    instruction = lines
    |> Enum.filter(fn line -> String.contains?(line, "->") end)
    |> Enum.map(fn line -> String.split(line, " ") |> List.delete_at(3) end)

    execute_system(system, instruction) |> get_binary_number() |> String.to_integer(2)
  end

  @spec ex2([String.t()]) :: String.t()
  def ex2(lines) do
    lines
    |> Enum.filter(fn line -> String.contains?(line, "->") end)
    |> Enum.map(fn line -> String.split(line, " ") |> List.delete_at(3) end)
    |> find_wires_to_be_swapped(44)
    |> Enum.sort()
    |> Enum.join(",")
  end
end
