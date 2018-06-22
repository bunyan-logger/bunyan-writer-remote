defmodule BunyanWriterRemoteTest do
  use ExUnit.Case
  doctest BunyanWriterRemote

  test "greets the world" do
    assert BunyanWriterRemote.hello() == :world
  end
end
