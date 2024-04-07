defmodule Templatelib.Application do
  use Application
  def start(_type, _args) do
    text = "<p>This {{ /get/from/path/thing | mask uppercase }} is a nice value!</p>"
    Templatelib.apply(text)
    |> IO.puts()
    {:ok, self()}
  end
end
