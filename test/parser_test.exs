defmodule ParserTest do
  alias Templatelib.Parser
  require Parser
  require NaryTree
  require NaryTree.Node
  require NodeData

  use ExUnit.Case, async: true

  doctest Templatelib.Parser

  test "parse all popping" do
    input =
      "<p>This data {{ get /documents/brazilian/cpf | as_string | padding 11 direction=left with=0 | mask ###.###.###-## }} is formatted as a Brazilian identification CPF</p>"

    tree = Parser.parse(input)
    root = NaryTree.root(tree)
    assert length(root.children) == 3

    node = get_following(root, [0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :text
    assert data.token == %Token{type: :ident, literal: "<p>This data "}

    node = get_following(root, [2], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :text
    assert data.token == %Token{type: :ident, literal: " is formatted as a Brazilian identification CPF</p>"}

    node = get_following(root, [1], tree)
    assert length(node.children) == 4
    data = node.content
    assert data.type == :expression
    assert data.token == :empty

    node = get_following(root, [1, 0], tree)
    assert length(node.children) == 1
    data = node.content
    assert data.type == :function
    assert data.token.type == :get

    node = get_following(root, [1, 0, 0], tree)
    assert length(node.children) == 1
    data = node.content
    assert data.type == :parameter_block
    assert data.token == :empty

    node = get_following(root, [1, 0, 0, 0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_value
    assert data.token == %Token{type: :ident, literal: "/documents/brazilian/cpf"}

    node = get_following(root, [1, 1], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :function
    assert data.token.type == :as_string

    node = get_following(root, [1, 2], tree)
    assert length(node.children) == 3
    data = node.content
    assert data.type == :function
    assert data.token.type == :padding

    node = get_following(root, [1, 2, 0], tree)
    assert length(node.children) == 2
    data = node.content
    assert data.type == :parameter_block
    assert data.token == :empty

    node = get_following(root, [1, 2, 0, 0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_name
    assert data.token == %Token{type: :ident, literal: "with"}

    node = get_following(root, [1, 2, 0, 1], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_value
    assert data.token == %Token{type: :number, literal: "0"}

    node = get_following(root, [1, 2, 1], tree)
    assert length(node.children) == 2
    data = node.content
    assert data.type == :parameter_block
    assert data.token == :empty

    node = get_following(root, [1, 2, 1, 0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_name
    assert data.token == %Token{type: :ident, literal: "direction"}

    node = get_following(root, [1, 2, 1, 1], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_value
    assert data.token == %Token{type: :ident, literal: "left"}

    node = get_following(root, [1, 2, 2], tree)
    assert length(node.children) == 1
    data = node.content
    assert data.type == :parameter_block
    assert data.token == :empty

    node = get_following(root, [1, 2, 2, 0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_value
    assert data.token == %Token{type: :number, literal: "11"}

    node = get_following(root, [1, 3], tree)
    assert length(node.children) == 1
    data = node.content
    assert data.type == :function
    assert data.token.type == :mask

    node = get_following(root, [1, 3, 0], tree)
    assert length(node.children) == 1
    data = node.content
    assert data.type == :parameter_block
    assert data.token == :empty

    node = get_following(root, [1, 3, 0, 0], tree)
    assert length(node.children) == 0
    data = node.content
    assert data.type == :parameter_value
    assert data.token == %Token{type: :ident, literal: "###.###.###-##"}
  end

  @spec get_following(NaryTree.Node.t(), [integer()], NaryTree.t()) :: NaryTree.Node.t()
  defp get_following(node, [], _), do: node
  defp get_following(root, [idx | indexes], tree),
    do:
      root
      |> NaryTree.children(tree)
      |> Enum.at(idx)
      |> get_following(indexes, tree)
end
