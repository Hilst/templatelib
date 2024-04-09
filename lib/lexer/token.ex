defmodule Token do
  @type keyword_types ::
          :mask
          | :get
          | :as_string
          | :padding
  @type token_type ::
          :ldsquirly
          | :rdsquirly
          | :pipe
          | :equal
          | :eof
          | keyword_types()
          | :ident
          | :number
          | :illegal

  defguard is_of_type(token, type) when token.type == type
  defguard is_keyword(token) when token.type in [:mask, :get, :as_string, :padding]

  defstruct type: nil, literal: nil
  @type t :: %Token{type: token_type(), literal: String.t()}

  @spec new(String.t(), token_type()) :: t()
  def new(string, type), do: %Token{type: type, literal: string}

  @spec new(token_type()) :: t()
  def new(:ldsquirly), do: new("{{", :ldsquirly)
  def new(:rdsquirly), do: new("}}", :rdsquirly)
  def new(:pipe), do: new("|", :pipe)
  def new(:equal), do: new("=", :equal)
  def new(:eof), do: new("", :eof)
  def new(:mask), do: new("mask", :mask)
  def new(:get), do: new("get", :get)
  def new(:as_string), do: new("as_string", :as_string)
  def new(:padding), do: new("padding", :padding)
end
