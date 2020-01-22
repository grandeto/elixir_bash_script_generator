defmodule ElixirBashScriptGeneratorTest do
  use ExUnit.Case
  doctest ElixirBashScriptGenerator

  test "greets the world" do
    assert ElixirBashScriptGenerator.hello() == :world
  end
end
