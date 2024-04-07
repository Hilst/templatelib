defmodule Templatelib do
  @moduledoc """
  Documentation for `Templatelib`.
  """
  alias Templatelib.Lexer
  def apply(template) do
    Lexer.run_lexer(template)
    |> Parser.run_parser
    # |> Analyzer.run_analysis
    # |> Builder.run_build
  end
end
