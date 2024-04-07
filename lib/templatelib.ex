defmodule Templatelib do
  @moduledoc """
  Documentation for `Templatelib`.
  """
  alias Templatelib.Lexer
  def apply(template) when is_binary(template) do
    all_tokens(template)
  end

  defp all_tokens(template) when is_binary(template) do
    get_tokens(template)
  end

  defp get_tokens(template, in_delimiter \\ false, acc \\ [])
  defp get_tokens(<<>>, _, acc) do
    acc
    |> Enum.reverse()
  end
  defp get_tokens(template, in_delimiter, acc) do
    { [token], rest, in_delimiter } = Lexer.next(template, :pop, in_delimiter)
    get_tokens(rest, in_delimiter, [token | acc])
  end
end
