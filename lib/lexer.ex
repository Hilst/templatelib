defmodule Templatelib.Lexer do
  @moduledoc """
  Lexer contain a single public function:

  run_lexer(String.t()) -> [Token.t()]
  """
  alias Templatelib.Types.Token

  defguardp is_whitespace(c) when c in ~c[ \n\t]

  defguardp is_letter(c)
            when c in ?a..?z or
                   c in ?A..?Z or
                   c == ?_ or
                   c == ?# or
                   c == ?.

  defguardp is_digit(c) when c in ?0..?9

  @type next_type :: :peek | :pop
  defguardp is_next_type(t) when t == :peek or t == :pop
  # NEXT PUBIC INTERFACE
  @spec next(input :: String.t(), type :: next_type(), inside_delimiter :: boolean(), deepth :: integer()) ::
          {[Token.t()], rest :: String.t(), inside_deleimiter :: boolean()}
  def next(input, next_type, inside \\ false, n \\ 1)
      when is_binary(input) and is_next_type(next_type) and is_integer(n),
      do: next(input, next_type, n, [], input, inside)

  # NEXT CALC
  @spec next(
          input :: String.t(),
          type :: next_type(),
          deepth :: integer(),
          tokens :: [Token.t()],
          rest :: String.t(),
          inside :: boolean()
        ) :: {[Token.t()], rest :: String.t(), inside_del :: boolean()}
  # NEXT RETURN
  defp next(input, next_type, _, [%Token{type: :eof, literal: _} | _] = tokens, rest, inside) when is_next_type(next_type) and is_boolean(inside) do
    returned_rest = case next_type do
      :peek -> input
      :pop -> rest
    end
    {tokens, returned_rest, inside}
  end
  defp next(input, :peek, 0, tokens, _rest, inside), do: {tokens, input, inside}
  defp next(_input, :pop, 0, tokens, rest, inside), do: {tokens, rest, inside}

  # NEXT CALC
  defp next(input, type, n, tokens, in_rest, inside) do
    {token, rest, entered_delimiter} = lex(in_rest, tokens, inside)
    next(input, type, n - 1, [token | tokens], rest, entered_delimiter)
  end

  # LEX CALC
  @spec lex(input :: String.t(), tokens :: [Token.t()], inside_delimiter :: boolean()) :: {Token.t(), String.t(), boolean()}
  # ANY POINT
  defp lex(<<>>, _tokens, _inside), do: {Token.new(:eof), <<>>} # EOF CASE
  # OUTSIDE DELIMITER
  defp lex(input, _tokens, false) when is_binary(input), do: read_until_open(input, <<>>)
  # INSIDE DELIMITER
  defp lex(<<c::8, rest::binary>>, tokens, true) when is_whitespace(c), do: lex(rest, tokens, true) # WHITESPACES
  defp lex(input, _tokens, true), do: tokenize(input) # TOKENIZATION

  @spec tokenize(input :: String.t()) :: {Token.t(), rest :: String.t(), stop :: boolean()}
  defp tokenize(<<"{{", rest::binary>>), do: {Token.new(:ldsquirly), rest, true}
  defp tokenize(<<"}}", rest::binary>>), do: {Token.new(:rdsquirly), rest, false}
  defp tokenize(<<"/", rest::binary>>), do: {Token.new(:slash), rest, true}
  defp tokenize(<<"|", rest::binary>>), do: {Token.new(:pipe), rest, true}
  defp tokenize(<<c::8, rest::binary>>) when is_letter(c), do: read_ident(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>) when is_digit(c), do: read_number(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>), do: {Token.new(<<c>>, :illegal), rest}

  @spec read_ident(String.t(), iodata()) :: {Token.t(), rest :: String.t(), true}
  defp read_ident(<<c::8, rest::binary>>, acc) when is_letter(c),
    do: read_ident(rest, acc <> <<c>>)

  defp read_ident(rest, acc), do: {IO.iodata_to_binary(acc) |> tokenize_word(), rest, true}

  @spec tokenize_word(String.t()) :: Token.t()
  defp tokenize_word("mask"), do: Token.new(:mask)
  defp tokenize_word(ident), do: Token.new(ident, :ident)

  @spec read_number(String.t(), iodata()) :: {Token.t(), rest :: String.t(), true}
  defp read_number(<<c::8, rest::binary>>, acc) when is_digit(c), do: read_number(rest, acc <> <<c>>)
  defp read_number(rest, acc), do: {IO.iodata_to_binary(acc) |> Token.new(:number), rest, true}

  @spec read_until_open(String.t(), iodata()) :: {Token.t(), rest :: String.t(), opened :: boolean()}
  defp read_until_open(<<"{{", _::binary>> = input, acc), do: {IO.iodata_to_binary(acc) |> Token.new(:ident), input, true}
  defp read_until_open(<<c::8, rest::binary>>, acc), do: read_until_open(rest, acc <> <<c>>)
  defp read_until_open(<<>>, acc), do: {IO.iodata_to_binary(acc) |> Token.new(:ident), <<>>, false}
end
