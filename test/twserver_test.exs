defmodule TwserverTest do
  use ExUnit.Case
  doctest Twserver

  test "greets the world" do
    assert Twserver.hello() == :world
  end
end
