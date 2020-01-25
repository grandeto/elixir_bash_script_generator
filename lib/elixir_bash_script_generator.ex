defmodule ElixirBashScriptGenerator do
    @moduledoc """
    Documentation for ElixirBashScriptGenerator.
    """

    # @first_task_name "task-1"

    @doc """
    Elixir Bash Script Generator

    ## Examples

        iex> ElixirBashScriptGenerator.generate(map)

    """
    def generate(data) when is_list(data) do
        %{"sorted" => sorted, "executed" => executed, "queued" => _queued} = sort_tasks(data)
        Enum.reverse(sorted)
    end

    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{"sorted" => [], "executed" => [], "queued" => %{}}, fn task, acc ->
            handle_tasks_sorting(task, acc)
        end)
    end

    def handle_tasks_sorting(task, acc) do
        if !task["requires"] do
            task = Map.delete(task, "in_queue")
            acc = Map.put(acc, "sorted", append_value_to_list_in_map(acc, "sorted", task))
            acc = Map.put(acc, "executed", append_value_to_list_in_map(acc, "executed", task, "name"))
            check_queued_on_task_executed(task, acc)
        else
            handle_task_requires(task, acc)
        end
    end

    def check_queued_on_task_executed(task, acc) do
        IO.inspect(acc)
        if acc["queued"][task["name"]] do
            queued = acc["queued"]
            task_queued_jobs = Enum.reverse(queued[task["name"]])
            queued = Map.delete(queued, task["name"])
            acc = Map.put(acc, "queued", queued)
            Enum.reduce(task_queued_jobs, acc, fn task_from_job, acc ->
                handle_tasks_sorting(task_from_job, acc)
            end)
        else
            acc
        end
    end

    def handle_task_requires(task, acc) do
        requires = task["requires"]
        requires = Enum.reduce(requires, [], fn req_task_name, req_acc ->
            if req_task_name in acc["executed"], do: req_acc, else: [req_task_name | req_acc]
        end)
        if Enum.empty?(requires) do
            task = Map.delete(task, "requires")
            handle_tasks_sorting(task, acc)
        else
            requires = should_be_queued(requires, task)
            if Enum.empty?(requires), do: acc, else: handle_add_to_queue(task, acc, requires)
        end
    end

    def should_be_queued(requires, task) do
        if task["in_queue"] do
            Enum.reduce(requires, [], fn req_task_name, should_be_queued_acc ->
                if req_task_name in task["in_queue"], do: should_be_queued_acc, else: [req_task_name | should_be_queued_acc]
            end)
        else
            Map.put(task, "in_queue", requires)
            requires
        end
    end

    def handle_add_to_queue(task, acc, requires) do
        Enum.reduce(requires, acc, fn req_task_name, acc ->
          if acc["queued"][req_task_name] do
            queued = append_value_to_list_in_map(acc["queued"], req_task_name, task)
            Map.put(acc, "queued", queued)
          else
            queued = acc["queued"]
            queued = Map.put(queued, req_task_name, [task])
            Map.put(acc, "queued", queued)
          end
        end)
    end

    def append_value_to_list_in_map(map, key, value, value_key \\ nil) do
        temp_list = map[key]
        value = if Kernel.is_nil(value_key), do: value, else: value[value_key]
        [value | temp_list]
    end
end
