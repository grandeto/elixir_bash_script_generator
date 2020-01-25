defmodule ElixirBashScriptGenerator do
    @moduledoc """
    Documentation for ElixirBashScriptGenerator.
    """

    @first_task_name "task-1"

    @doc """
    Elixir Bash Script Generator

    ## Examples

        iex> ElixirBashScriptGenerator.generate(map)

    """
    def generate(data) when is_list(data) do
        %{"sorted" => sorted, "executed" => executed, "queued" => _} = sort_tasks(data)
        IO.inspect(executed)
        sorted
    end

    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{"sorted" => [], "executed" => [], "queued" => %{}}, fn task, acc ->
            handle_tasks_sorting(task, acc)
        end)
    end

    def handle_tasks_sorting(task, acc) do
        if task["name"] === @first_task_name do
            acc = add_to_acc(task, acc, "sorted")
            add_to_acc(task, acc, "executed", "name")
        else
            handle_tail_tasks_sorting(task, acc)
        end
    end

    def handle_tail_tasks_sorting(task, acc) do
        if task["requires"] && (List.last(task["requires"]) in acc["executed"]) do
            acc = add_to_acc(task, acc, "sorted")
            add_to_acc(task, acc, "executed", "name")
            handle_queued_tasks(acc, task["name"])
        else
            # TODO: add_to_queued_tasks
            acc
        end
    end

    def handle_queued_tasks(acc, executed_task_name) do
        %{
            "sorted" => [],
            "executed" => [],
            "queued" => %{"task-5" => [
                                        %{
                                            "name" => "task-2",
                                            "command" => "cat /tmp/file1",
                                            "requires" => [
                                                "task-5"
                                            ]
                                        },
                                        %{
                                            "name" => "task-3",
                                            "command" => "cat /tmp/file1",
                                            "requires" => [
                                                "task-5"
                                            ]
                                        }
                                    ]
                        }
        }
        queue = acc["queued"]
        if queue[executed_task_name] do
            {task, left_queued_tasks} = List.pop_at(queue[executed_task_name], 0)
            acc = add_to_acc(task, acc, "sorted")
            acc = add_to_acc(task, acc, "executed", "name")
            # TODO finish this
            # TODO validate requires are sequenced
        end
    end

    def append_task_to_list(task, map, key, task_key) do
        temp_list = map[key]
        value = if Kernel.is_nil(task_key), do: task, else: task[task_key]
        List.insert_at(temp_list, -1, value)
    end

    def add_to_acc(task, acc, acc_key, task_key \\ nil) do
        Map.put(acc, acc_key, append_task_to_list(task, acc, acc_key, task_key))
    end
end
