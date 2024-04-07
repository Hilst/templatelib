defmodule Templatelib.Types do
  @moduledoc """
  Types contains all types used template lib
  Token, Pars
  """
  defmodule Token do
    @type keyword_types ::
            :mask
    @type token_type ::
            :ldsquirly
            | :rdsquirly
            | :slash
            | :pipe
            | :eof
            | keyword_types()
            | :ident
            | :number
            | :illegal

    defstruct type: nil, literal: nil
    @type t :: %Token{type: token_type(), literal: String.t()}

    @spec new(String.t(), token_type()) :: t()
    def new(string, type), do: %Token{type: type, literal: string}

    @spec new(token_type()) :: t()
    def new(:ldsquirly), do: new("{{", :ldsquirly)
    def new(:rdsquirly), do: new("}}", :rdsquirly)
    def new(:slash), do: new("/", :slash)
    def new(:pipe), do: new("|", :pipe)
    def new(:eof), do: new("", :eof)
    def new(:mask), do: new("mask", :mask)
  end

  defmodule AST do
    alias Templatelib.Types.AST.ASTNode
    defstruct nodes: []
    @type t :: %AST{nodes: [ASTNode.t()]}

    defmodule ASTNode do
      defstruct tokens: [], nodes: []
      @type t :: %ASTNode{tokens: [Token.t()], nodes: [ASTNode.t()]}
    end
  end
end
