defmodule ParserTest do
  alias Templatelib.Parser
  alias Templatelib.Types.Token
  alias Templatelib.Types.ASTNode

  use ExUnit.Case, async: true

  doctest Templatelib.Parser

  test "parse all popping" do
    input =
      "<p>This data {{ get /documents/brazilian/cpf | as_string | padding direction=left with=0 until=11 | mask ###.###.###-## }} is formatted as a Brazilian identification CPF</p>"

    tree = Parser.parse(input)
    f = tree.nodes |> Enum.at(0)
    assert f == ASTNode.new([Token.new("<p>This data ", :ident)], [], :text)
    t = tree.nodes |> Enum.at(2)
    assert t == ASTNode.new([Token.new(" is formatted as a Brazilian identification CPF</p>", :ident)], [], :text)
  end
end
