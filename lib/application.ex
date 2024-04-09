defmodule Templatelib.Application do
  alias Templatelib.Parser
  use Application

  def start(_type, _args) do
    text =
      "<p>This data {{ get /documents/brazilian/cpf | as_string | padding 11 direction=left with=0  | mask ###.###.###-## }} is formatted as a Brazilian identification CPF</p>"

    Parser.parse(text)
    |> NaryTree.print_tree

    {:ok, self()}
  end
end
