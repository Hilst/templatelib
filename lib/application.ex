defmodule Templatelib.Application do
  alias Templatelib.Parser
  use Application
  def start(_type, _args) do
    text = "<p>This {{ /get/from/path/thing | mask uppercase }} is a nice value!</p>"
    Templatelib.hello()
    Parser.parse(text)
    {:ok, self()}
  end
end
