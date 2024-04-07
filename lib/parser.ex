defmodule Parser do
  @moduledoc """
  Parser provide run_parser which parse a Token list and builts a AST
  """
  alias Templatelib.Types.AST
  alias Templatelib.Types.Token

  @spec run_parser([Token.t()]) :: AST.t()
  def run_parser(_tokens) do
    %AST{}
  end
end
