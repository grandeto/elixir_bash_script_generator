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
    def sort(data) when is_list(data) do
        %{"sorted" => sorted, "executed" => _executed, "queued" => _queued} = sort_tasks(data)
        Enum.reverse(sorted)
    end

    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{"sorted" => [], "executed" => [], "queued" => %{}}, fn task, acc ->
            handle_tasks_sorting(task, acc)
        end)
    end

    def handle_tasks_sorting(task, acc) do
        if task["name"] in acc["executed"] do
            acc
        else
            if !task["requires"] do
                task = Map.delete(task, "in_queue")
                acc = Map.put(acc, "sorted", append_value_to_list_in_map(acc, "sorted", task))
                acc = Map.put(acc, "executed", append_value_to_list_in_map(acc, "executed", task, "name"))
                check_execute_queued_tasks(task, acc)
            else
                handle_task_requires(task, acc)
            end
        end
    end

    def check_execute_queued_tasks(task, acc) do
        if Map.has_key?(acc["queued"], task["name"]) do
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
            {requires, task} = should_be_queued(requires, task)
            if Enum.empty?(requires), do: acc, else: handle_add_to_queue(task, acc, requires)
        end
    end

    def should_be_queued(requires, task) do
        if task["in_queue"] do
            in_queue = task["in_queue"]
            requires = Enum.reduce(requires, [], fn req_task_name, should_be_queued_acc ->
                if req_task_name in in_queue do
                  should_be_queued_acc
                else
                  in_queue = [req_task_name | in_queue]
                  [req_task_name | should_be_queued_acc]
                end
            end)
            task = Map.put(task, "in_queue", in_queue)
            {requires, task}
        else
            task = Map.put(task, "in_queue", requires)
            {requires, task}
        end
    end

    def handle_add_to_queue(task, acc, requires) do
        Enum.reduce(requires, acc, fn req_task_name, acc ->
          if Map.has_key?(acc["queued"], req_task_name) do
            queued = acc["queued"]
            queued = Map.put(queued, req_task_name, append_value_to_list_in_map(queued, req_task_name, task))
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
