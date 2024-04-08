defmodule Templatelib.Parser do
  @moduledoc """
  Parser provide run_parser which parse a Token list and builts a AST
  """
  alias Templatelib.Lexer
  alias Templatelib.Types.Token

  @typep pg :: :digraph.graph()
  @typep lexin :: {String.t(), Lexer.next_type(), boolean()}
  @typep lexout :: {[Token.t()], String.t(), boolean()}

  @spec parse(String.t()) :: pg()
  def parse(input) do
    g = :digraph.new()
    parse({input, :pop, false}, g)
  end

  @spec parse(lexin(), pg()) :: pg()
  defp parse({input, lextype, inside}, ast) do

    Lexer.next(input, lextype, inside)
    |> handle(ast)
  end

  @spec handle(lexout(), pg()) :: pg()
  defp handle({[token], rest, inside}, ast) do
    IO.inspect token
    IO.inspect rest
    IO.inspect inside
    ast
  end
end
