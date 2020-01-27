defmodule ElixirBashScriptGenerator do
    @moduledoc """
    Documentation for Elixir Bash Script Generator.
    """

    @doc """
    Generate Bash Commands Endpoint

    ## Examples

        curl -v -H 'Content-Type: application/json' "http://localhost:4000/generate" -d @print_text_task_2.json | bash

    """
    @spec generate(maybe_improper_list) :: bitstring
    def generate(data) when is_list(data) do
        sort(data)
        |> Enum.reduce("", fn task, acc ->
            acc <> task["command"] <> "\n"
        end)
    end

    @doc """
    Get Sorted Bash Commands Endpoint

    ## Examples

        POST http://localhost:4000/sort

        Content-Type: application/json

        Body example:
        {
            "tasks":[
                {
                    "name":"task-1",
                    "command":"touch file"
                },
                {
                    "name":"task-2",
                    "command":"cat file",
                    "requires":[
                        "task-3"
                    ]
                },
                {
                    "name":"task-3",
                    "command":"echo 'Hello World!' > file",
                    "requires":[
                        "task-1"
                    ]
                },
                {
                    "name":"task-4",
                    "command":"rm file",
                    "requires":[
                        "task-2",
                        "task-3"
                    ]
                }
            ]
        }
    """
    @spec sort(maybe_improper_list) :: [any]
    def sort(data) when is_list(data) do
        %{"sorted" => sorted, "executed" => _executed, "queued" => _queued} = sort_tasks(data)
        Enum.reverse(sorted)
    end

    @doc """
    Init the Commands Sorting Algorithm
    """
    @spec sort_tasks(list) :: map
    def sort_tasks(tasks) do
        Enum.reduce(tasks, %{"sorted" => [], "executed" => [], "queued" => %{}}, fn task, acc ->
            handle_tasks_sorting(task, acc)
        end)
    end

    @doc """
    Internal router for the Commands Sorting Algorithm.

    Takes the Decision to sort, queue, re-execute, mark as executed or skip a given task
    """
    @spec handle_tasks_sorting(map, map) :: map
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

    @doc """
    Checks queued tasks and execute them if needed
    """
    @spec check_execute_queued_tasks(map, map) :: map
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

    @doc """
    Get actual single task dependencies
    """
    @spec handle_task_requires(map, map) :: map
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

    @doc """
    Determinate those task dependencies that need to be queued and mark them as queued
    """
    @spec should_be_queued(list, map) :: {list, map}
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

    @doc """
    Add task to queue
    """
    @spec handle_add_to_queue(map, map, list) :: map
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

    @doc """
    Append value to list in map
    """
    @spec append_value_to_list_in_map(map, bitstring, map | bitstring, bitstring | nil) ::
            nonempty_maybe_improper_list
    def append_value_to_list_in_map(map, key, value, value_key \\ nil) do
        temp_list = map[key]
        value = if Kernel.is_nil(value_key), do: value, else: value[value_key]
        [value | temp_list]
    end
end
