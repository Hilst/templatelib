defmodule LexerTest do
  alias Templatelib.Lexer
  alias Templatelib.Types.Token
  use ExUnit.Case, async: true

  doctest Templatelib.Lexer

  test "tokenize all popping" do
    input =
      "<p>This data {{ get /documents/brazilian/cpf | as_string | padding direction=left with=0 until=11 | mask ###.###.###-## }} is formatted as a Brazilian identification CPF</p>"

    {[token], rest, inside} = Lexer.next(input, :pop)
    expected = Token.new("<p>This data ", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:ldsquirly)
    assert token == expected
    assert inside == true
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:get)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("/documents/brazilian/cpf", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:pipe)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:as_string)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:pipe)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:padding)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("direction", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:equal)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("left", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("with", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:equal)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("0", :number)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("until", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:equal)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("11", :number)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:pipe)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:mask)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new("###.###.###-##", :ident)
    assert token == expected
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:rdsquirly)
    assert token == expected
    assert inside == false
    {[token], rest, inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(" is formatted as a Brazilian identification CPF</p>", :ident)
    assert token == expected
    {[token], rest, _inside} = Lexer.next(rest, :pop, inside)
    expected = Token.new(:eof)
    assert token == expected
    assert rest == <<>>
  end
end
