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

  @doc """
  Tokenize an input text into template tokens code with {{ }} delimiters

  ## Example

    iex> Templatelib.Lexer.run_lexer("<p>This {{ /get/from/path/thing | mask uppercase }} is nice!</p>")
    [
      {:ident, "<p>This "},
      :ldsquirly,
      :slash,
      {:ident, "get"},
      :slash,
      {:ident, "from"},
      :slash,
      {:ident, "path"},
      :slash,
      {:ident, "thing"},
      :pipe,
      :mask,
      {:ident, "uppercase"},
      :rsquirly,
      {:ident, "is nice!</p>"},
      :eof
    ]
  """

  @spec run_lexer(String.t()) :: [Token.t()]
  def run_lexer(input) when is_binary(input) do
    lex(input, [], false)
  end

  @spec lex(input :: String.t(), [Token.t()], inside_dsquirly :: boolean()) :: [Token.t()]
  # Empty input stop with tokens + eof
  defp lex(<<>>, tokens, _) do
    [:eof | tokens] |> Enum.reverse()
  end

  defp lex(input, tokens, false) do
    case read_until_open(input, <<>>) do
      {token, <<>>, _} -> lex(<<>>, [token | tokens], false)
      {token, rest, true} -> lex(rest, [token | tokens], true)
      _ -> lex(<<>>, tokens, false)
    end
  end

  # Ignore whitespaces
  defp lex(<<c::8, rest::binary>>, tokens, true) when is_whitespace(c) do
    lex(rest, tokens, true)
  end

  # Call tokenize apllication recursively
  defp lex(input, tokens, true) do
    {token, rest, stop} = tokenize(input)
    lex(rest, [token | tokens], !stop)
  end

  @spec tokenize(input :: String.t()) :: {Token.t(), rest :: String.t(), stop :: boolean()}
  defp tokenize(<<"{{", rest::binary>>), do: {Token.new(:ldsquirly), rest, false}
  defp tokenize(<<"}}", rest::binary>>), do: {Token.new(:rdsquirly), rest, true}
  defp tokenize(<<"/", rest::binary>>), do: {Token.new(:slash), rest, false}
  defp tokenize(<<"|", rest::binary>>), do: {Token.new(:pipe), rest, false}
  defp tokenize(<<c::8, rest::binary>>) when is_letter(c), do: read_ident(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>) when is_digit(c), do: read_number(rest, <<c>>)
  defp tokenize(<<c::8, rest::binary>>), do: {Token.new(<<c>>, :illegal), rest}

  @spec read_ident(String.t(), iodata()) :: {Token.t(), rest :: String.t(), false}
  defp read_ident(<<c::8, rest::binary>>, acc) when is_letter(c),
    do: read_ident(rest, acc <> <<c>>)

  defp read_ident(rest, acc), do: {IO.iodata_to_binary(acc) |> tokenize_word(), rest, false}

  @spec tokenize_word(String.t()) :: Token.t()
  defp tokenize_word("mask"), do: Token.new(:mask)
  defp tokenize_word(ident), do: Token.new(ident, :ident)

  @spec read_number(String.t(), iodata()) :: {Token.t(), rest :: String.t(), false}
  defp read_number(<<c::8, rest::binary>>, acc) when is_digit(c),
    do: read_number(rest, acc <> <<c>>)

  defp read_number(rest, acc), do: {IO.iodata_to_binary(acc) |> Token.new(:number), rest, false}

  @spec read_until_open(String.t(), iodata()) ::
          {Token.t(), rest :: String.t(), opened :: boolean()}
  defp read_until_open(<<"{{", _::binary>> = input, acc),
    do: {IO.iodata_to_binary(acc) |> Token.new(:ident), input, true}

  defp read_until_open(<<c::8, rest::binary>>, acc), do: read_until_open(rest, acc <> <<c>>)

  defp read_until_open(<<>>, acc),
    do: {IO.iodata_to_binary(acc) |> Token.new(:ident), <<>>, false}
end
