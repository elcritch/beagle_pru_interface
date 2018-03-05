defmodule PruInterfaceTest do
  use ExUnit.Case
  doctest PruInterface

  test "greets the world" do
    assert PruInterface.hello() == :world
  end
end
