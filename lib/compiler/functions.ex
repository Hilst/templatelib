defmodule Compiler.FunctionsDefined do
  def run(%{name: "get", params: p}, data, _), do: f_get(Map.get(p, "0", ""), data)
  def run(%{name: "as_string"}, _, input), do: f_as_string(input)

  def run(%{name: "padding", params: p}, _, input),
    do:
      f_padding(
        input,
        Map.get(p, "0", 0),
        Map.get(p, "direction", "left"),
        Map.get(p, "with", " ")
      )

  def run(%{name: "mask", params: p}, _, input), do: f_mask(input, Map.get(p, "0", ""), <<>>)

  def run(f, data, c) do
    require IEx
    IEx.pry()
    c
  end

  defp f_get(path, data) when is_binary(path),
    do: f_get(String.split(path, <<"/">>, trim: true), data)

  defp f_get(_, nil), do: nil
  defp f_get([part | rest], data) when is_map(data), do: f_get(rest, Map.get(data, part))

  defp f_get([part | rest], data) when is_list(data) do
    case Integer.parse(part) do
      {idx, _} -> f_get(rest, Enum.at(data, idx, nil))
      :error -> nil
    end
  end

  defp f_get([], d) when is_float(d) or is_integer(d) or is_binary(d) or is_boolean(d), do: d
  defp f_get([], _), do: nil

  defp f_as_string(input), do: to_string(input)

  defp f_padding(string, size, direction, pad) do
    count =
      case Integer.parse(size) do
        {int, _} -> int
        :error -> 0
      end

    pad_func =
      case direction do
        "right" -> &String.pad_trailing/3
        _ -> &String.pad_leading/3
      end

    pad_func.(string, count, pad)
  end

  defp f_mask(<<c_in::8, rest_in::binary>>, <<c_pt::8, rest_pt::binary>>, output) when c_pt == ?#,
    do: f_mask(rest_in, rest_pt, output <> <<c_in>>)

  defp f_mask(input, <<c_pt::8, rest_pt::binary>>, output) when c_pt != ?#,
    do: f_mask(input, rest_pt, output <> <<c_pt>>)

  defp f_mask(<<>>, _, output), do: output
  defp f_mask(input, <<>>, output), do: output <> input
end
