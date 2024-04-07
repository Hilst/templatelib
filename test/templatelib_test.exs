defmodule TemplatelibTest do
  use ExUnit.Case
  doctest Templatelib

  test "greets the world" do
    assert Templatelib.hello() == :world
  end
end
