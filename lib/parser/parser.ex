defmodule Templatelib.Parser do
  @moduledoc """
  Parser provide run_parser which parse a Token list and builts a AST
  """
  require Token
  alias NodeData
  alias Templatelib.Lexer
  alias NaryTree
  alias NaryTree.Node

  @typep tree :: NaryTree.t()
  @typep tree_node :: Node.t()

  @typep lex_in :: {String.t(), Lexer.next_type(), boolean()}
  @typep lex_out :: {[Token.t()], String.t(), boolean()}

  @spec parse(String.t()) :: tree()
  def parse(input) do
    root = create_node(NodeData.new())
    tree = NaryTree.new(root)
    parse({input, :pop, false}, tree, root)
  end

  @spec parse(lex_in(), tree(), parent :: tree_node()) :: tree()
  defp parse({input, lextype, inside}, ast, parent) do
    Lexer.next(input, lextype, inside)
    |> handle(ast, parent.id)
  end

  @spec handle(lex_out(), tree(), String.t()) :: tree()
  defp handle({[token], _, false}, ast, _) when Token.is_of_type(token, :eof), do: ast

  defp handle({[token], rest, inside}, ast, parent_id) when Token.is_of_type(token, :ident) do
    textNode =
      token
      |> NodeData.new(:text)
      |> create_node()

    ast = NaryTree.add_child(ast, textNode, parent_id)
    rootNode = NaryTree.root(ast)
    parse({rest, :pop, inside}, ast, rootNode)
  end

  defp handle({[token], rest, true}, ast, parent_id) when Token.is_of_type(token, :ldsquirly) do
    expressionNode =
      NodeData.new(:expression)
      |> create_node()

    ast = NaryTree.add_child(ast, expressionNode, parent_id)
    parse({rest, :pop, true}, ast, expressionNode)
  end

  defp handle({tokens, rest, true}, ast, parent_id) do
    {tokens, rest, inside} = lex_until_end_expression(rest, tokens, true)
    if inside do
      functionNode = create_function_node(tokens)
      ast = NaryTree.add_child(ast, functionNode, parent_id)
      parse({rest, :pop, inside}, ast, NaryTree.get(ast, parent_id))
    else
      parent =
        NaryTree.get(ast, parent_id) # parent :: :expression
        |> NaryTree.parent(ast) # parent parent :: :block
      parent_id = parent.id
      parse({rest, :pop, inside}, ast, NaryTree.get(ast, parent_id))
    end
  end

  defp lex_until_end_expression(rest, [last_token | _] = tokens, inside)
       when Token.is_of_type(last_token, :pipe) or Token.is_of_type(last_token, :rdsquirly),
       do: {tokens |> Enum.reverse(), rest, inside}

  defp lex_until_end_expression(rest, tokens, _) do
    {[token], rest, inside} = Lexer.next(rest, :pop, true)
    lex_until_end_expression(rest, [token | tokens], inside)
  end

  defp create_function_node(tokens) do
    [funcDeclarationTk | _paramsTks] = tokens
      NodeData.new(funcDeclarationTk, funcDeclarationTk.type)
      |> create_node()
    # params = creat_params()
    # [ funcNode | create_params(paramsTks)]
  end
  # defp create_params([  ], _paramsNodes) do
  # end
  # defp creat_params([])

  @spec create_node(NodeData.t()) :: tree_node()
  defp create_node(data), do: Node.new("#{data}", data)
end

defmodule NodeData do
  @type node_type ::
          :block
          | :text
          | :expression
          | :function
          | :parameter_name
          | :parameter_value

  defstruct token: :empty, type: :empty
  @type t :: %NodeData{token: Token.t(), type: node_type()}

  @spec new() :: NodeData.t()
  def new(), do: %NodeData{type: :block}

  @spec new(node_type()) :: NodeData.t()
  def new(type), do: %NodeData{type: type}

  @spec new(Token.t(), node_type()) :: __MODULE__.t()
  def new(token, type), do: %__MODULE__{type: type, token: token}

  defimpl String.Chars, for: NodeData do
    def to_string(%NodeData{token: tk, type: tp}) do
      if tk == :empty do
        "node-#{tp}"
      else
        "node-#{tp}-#{tk.type}>#{tk.literal}"
      end
    end
  end
end
