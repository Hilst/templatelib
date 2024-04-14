defmodule Templatelib.Application do
  use Application

  def start(_type, _args) do
    text =
      "<p>This data {{ get /documents/brazilian/cpf | as_string | padding 11 direction=left with=0  | mask ###.###.###-## }} is formatted as a Brazilian identification CPF</p>"

    data = %{
      "documents" => %{
        "brazilian" => %{
          "cpf" => 1_234_567_890
        }
      }
    }

    text |> Compiler.Compiler.compile(data) |> IO.inspect()
    {:ok, self()}
  end
end
