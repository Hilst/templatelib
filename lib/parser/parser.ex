defmodule Templatelib.Parser do
  @moduledoc """
  Parser provide run_parser which parse a Token list and builts a AST
  """
  require Token
  require NodeData
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
      ast = create_function_node(tokens, ast, parent_id)
      parse({rest, :pop, inside}, ast, NaryTree.get(ast, parent_id))
    else
      # parent :: :expression
      parent =
        NaryTree.get(ast, parent_id)
        # parent parent :: :block
        |> NaryTree.parent(ast)

      parent_id = parent.id
      parse({rest, :pop, inside}, ast, NaryTree.get(ast, parent_id))
    end
  end

  @spec lex_until_end_expression(String.t(), [Token.t()], boolean()) ::
          {[Token.t()], String.t(), boolean()}
  defp lex_until_end_expression(rest, [last_token | _] = tokens, inside)
       when Token.is_of_type(last_token, :pipe) or Token.is_of_type(last_token, :rdsquirly),
       do: {tokens |> Enum.reverse(), rest, inside}

  defp lex_until_end_expression(rest, tokens, _) do
    {[token], rest, inside} = Lexer.next(rest, :pop, true)
    lex_until_end_expression(rest, [token | tokens], inside)
  end

  @spec create_function_node([Token.t()], tree(), parent_id :: String.t()) :: tree()
  # WITHOUT PARAMS
  defp create_function_node([functionTk], ast, parent_id) do
    functionNode =
      NodeData.new(functionTk, :function)
      |> create_node()

    NaryTree.add_child(ast, functionNode, parent_id)
  end

  # WITH PARAMS
  defp create_function_node([functionTk | paramsTks], ast, parent_id) do
    functionNode =
      NodeData.new(functionTk, :function)
      |> create_node()

    ast = NaryTree.add_child(ast, functionNode, parent_id)
    create_params(paramsTks |> Enum.reverse(), ast, functionNode)
  end

  @spec create_params([Token.t()], tree(), tree_node()) :: tree()
  defp create_params([], ast, _), do: ast

  defp create_params([last | _ = []], ast, %NaryTree.Node{content: data})
       when (NodeData.is_node_data_type(data, :function) and Token.is_of_type(last, :pipe)) or
              Token.is_of_type(last, :ldsquirly) do
    ast
  end

  defp create_params([last | paramsTks], ast, node)
       when Token.is_of_type(last, :pipe) or Token.is_of_type(last, :ldsquirly) do
    create_params(paramsTks, ast, node)
  end

  defp create_params(paramsTks, ast, %NaryTree.Node{id: parent_id, content: data})
       when NodeData.is_node_data_type(data, :function) do
    paramsBlockNode =
      NodeData.new(:parameter_block)
      |> create_node()

    ast = NaryTree.add_child(ast, paramsBlockNode, parent_id)
    create_params(paramsTks, ast, paramsBlockNode)
  end

  defp create_params([value, equal, key | tokens], ast, %NaryTree.Node{id: parent_id, content: data})
       when Token.is_of_type(equal, :equal) and NodeData.is_node_data_type(data, :parameter_block) do
    keyNode =
      NodeData.new(key, :parameter_name)
      |> create_node()

    ast = NaryTree.add_child(ast, keyNode, parent_id)

    valueNode =
      NodeData.new(value, :parameter_value)
      |> create_node()

    ast = NaryTree.add_child(ast, valueNode, parent_id)

    ast = NaryTree.add_child(ast, valueNode, parent_id)
    parent =
      NaryTree.get(ast, parent_id)
      |> NaryTree.parent(ast)
    create_params(tokens, ast, parent)
  end

  defp create_params([value | tokens], ast, %NaryTree.Node{id: parent_id, content: data})
    when NodeData.is_node_data_type(data, :parameter_block)  do
    valueNode =
      NodeData.new(value, :parameter_value)
      |> create_node()

    ast = NaryTree.add_child(ast, valueNode, parent_id)
    parent =
      NaryTree.get(ast, parent_id)
      |> NaryTree.parent(ast)
    create_params(tokens, ast, parent)
    end

  @spec create_node(NodeData.t()) :: tree_node()
  defp create_node(data), do: Node.new("#{data}", data)
end
