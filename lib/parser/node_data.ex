defmodule NodeData do

  @type node_type ::
          :block
          | :text
          | :expression
          | :function
          | :parameter_block
          | :parameter_name
          | :parameter_value

  defguard is_node_data_type(node_data, type) when node_data.type == type

  defstruct token: :empty, type: :empty
  @type t :: %NodeData{token: Token.t() | :empty, type: node_type() | :empty}

  @spec new() :: NodeData.t()
  def new(), do: %NodeData{type: :block}

  @spec new(node_type()) :: NodeData.t()
  def new(type), do: %NodeData{type: type}

  @spec new(Token.t(), node_type()) :: NodeData.t()
  def new(token, type), do: %NodeData{type: type, token: token}

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
