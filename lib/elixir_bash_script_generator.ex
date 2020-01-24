defmodule ElixirBashScriptGenerator do
    @moduledoc """
    Documentation for ElixirBashScriptGenerator.
    """

    @first_task_name "task-1"

    @doc """
    Hello world.

    ## Examples

        iex> ElixirBashScriptGenerator.generate(map)

    """
    def generate(data) when is_list(data) do
        data
    end

    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{}, fn task, sorted_tasks ->

        end)
    end
end
