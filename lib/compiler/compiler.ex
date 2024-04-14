defmodule Compiler.Compiler do
  require NodeData
  alias Compiler.FunctionsDefined
  alias Templatelib.Parser
  alias NaryTree
  alias NaryTree.Node

  @spec compile(input :: String.t(), data :: any()) :: String.t()
  def compile(input, data) do
    ast = Parser.parse(input)
    root = NaryTree.root(ast)
    compile_tree(ast, root, data)
  end

  @spec compile_tree(ast :: Parser.tree(), node :: Parser.tree_node(), data :: any()) ::
          String.t()
  defp compile_tree(ast, current, data),
    do: compile_nodes(merge(current, ast, []), ast, data, <<>>)

  @spec compile_nodes(
          nodes :: [Parser.tree_node()],
          ast :: Parser.tree_node(),
          any(),
          output :: iodata()
        ) :: String.t()
  defp compile_nodes([], _, _, output), do: IO.iodata_to_binary(output)

  defp compile_nodes(
         [%Node{content: node_data} = parent | nodes],
         ast,
         data,
         output
       )
       when NodeData.is_node_data_type(node_data, :block),
       do:
         compile_nodes(
           merge(parent, ast, nodes),
           ast,
           data,
           output
         )

  defp compile_nodes(
         [%Node{content: node_data} | nodes],
         ast,
         data,
         output
       )
       when NodeData.is_node_data_type(node_data, :text),
       do:
         compile_nodes(
           nodes,
           ast,
           data,
           output <> node_data.token.literal
         )

  defp compile_nodes(
         [%Node{content: node_data} = parent | nodes],
         ast,
         data,
         output
       )
       when NodeData.is_node_data_type(node_data, :expression) do
    function_output = compile_functions(parent, ast, data, nil)
    compile_nodes(nodes, ast, data, output <> function_output)
  end

  defp compile_functions(%Node{content: node_data} = node, ast, data, current)
       when NodeData.is_node_data_type(node_data, :expression),
       do:
         NaryTree.children(node, ast)
         |> build_function(ast, [])
         |> Enum.reverse()
         |> solve_functions(data, current)

  defp build_function([], _, params_list), do: params_list

  defp build_function([%Node{content: node_data} = node | nodes], ast, params_list)
       when NodeData.is_node_data_type(node_data, :function) do
    children = NaryTree.children(node, ast)

    f = %{
      name: node_data.token.literal
    }

    if length(children) > 0 do
      p = build_params_block(children, ast, %{})
      f_with_params = Map.put(f, :params, p)
      build_function(nodes, ast, [f_with_params | params_list])
    else
      build_function(nodes, ast, [f | params_list])
    end
  end

  defp build_params_block([block | other_params_block], ast, function_map) do
    params = NaryTree.children(block, ast)
    builded_params = build_params(params, %{})
    build_params_block(other_params_block, ast, Map.merge(function_map, builded_params))
  end

  defp build_params_block([], _, function_map), do: function_map

  defp build_params([%Node{content: first}, %Node{content: second}], pMap)
       when NodeData.is_node_data_type(first, :parameter_name) and
              NodeData.is_node_data_type(second, :parameter_value),
       do: build_params(first.token.literal, second.token.literal, pMap)

  defp build_params([%Node{content: data}], pMap), do: build_params(0, data.token.literal, pMap)

  defp build_params(key, value, pMap) when is_binary(key) and is_map(pMap),
    do: Map.put_new(pMap, key, value)

  defp build_params(key, value, pMap)
       when is_integer(key) and is_map(pMap) do
    if Map.has_key?(pMap, to_string(key)) do
      build_params(key + 1, value, pMap)
    else
      build_params(to_string(key), value, pMap)
    end
  end

  defp solve_functions([f | next_functions], data, current) do
    output = FunctionsDefined.run(f, data, current)
    solve_functions(next_functions, data, output)
  end

  defp solve_functions([], _data, current), do: to_string(current)

  defp merge(node, ast, nodes),
    do: NaryTree.children(node, ast) |> Enum.concat(nodes)
end
