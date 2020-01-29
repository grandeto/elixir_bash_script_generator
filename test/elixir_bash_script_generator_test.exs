defmodule ElixirBashScriptGeneratorTest do
  use ExUnit.Case
  doctest ElixirBashScriptGenerator

  test "bash tasks are sorted correctly" do
    sorted = Poison.decode!(File.read!("./bash_tasks/print_text_task_1.json"))
    |> Map.get("tasks")
    |> ElixirBashScriptGenerator.sort()

    assert sorted === [
        %{"command" => "touch file1", "name" => "task-1"},
        %{"command" => "echo 'Hello World!' > file1", "name" => "task-3"},
        %{"command" => "cat file1", "name" => "task-2"},
        %{"command" => "rm file1", "name" => "task-4"}
      ]
  end
end
