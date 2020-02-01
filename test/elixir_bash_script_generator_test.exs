defmodule ElixirBashScriptGeneratorTest do
  use ExUnit.Case
  doctest ElixirBashScriptGenerator

  test "bash tasks are sorted correctly" do
    sorted = Poison.decode!(File.read!("./bash_tasks/print_text_task_2.json"))
    |> Map.get("tasks")
    |> ElixirBashScriptGenerator.sort()

    assert sorted === [
        %{"command" => "touch file2", "name" => "task-1"},
        %{"command" => "echo 'Hello World!' > file2", "name" => "task-3"},
        %{"command" => "cat file2", "name" => "task-5"},
        %{"command" => "ls -lah file2", "name" => "task-2"},
        %{"command" => "pwd", "name" => "task-4"}
      ]
  end
end
