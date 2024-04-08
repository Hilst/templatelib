defmodule ASTNode do
  @type node_type ::
          :text
          | :block
          | :expression
          | :function

  defstruct tokens: [], type: nil
  @type t :: %ASTNode{tokens: [Token.t()], type: node_type()}
end
