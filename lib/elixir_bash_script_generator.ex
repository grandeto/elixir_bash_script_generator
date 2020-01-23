defmodule ElixirBashScriptGenerator do
    @moduledoc """
    Documentation for ElixirBashScriptGenerator.
    """

    @first_task_name "task-1"

    @doc """
    Hello world.

    ## Examples

        iex> ElixirBashScriptGenerator.sort(map)

    """
    def generate(data) do
        %{"tasks" => tasks} = data
        IO.inspect(sort_tasks(tasks))
    end

    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{}, fn task, sorted_tasks ->

        end)
    end
end
