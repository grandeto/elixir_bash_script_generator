defmodule Middleware.Http.Validator do
    def body_is_map(data) do
        if Kernel.is_map(data) do
            {:ok, data}
        else
            {:error, "Wrong data format"}
        end
    end

    def tasks_is_list(data) do
        if Kernel.is_list(data) do
            {:ok, data}
        else
            {:error, "Wrong data format"}
        end
    end

    def tasks_ids_are_sequence(tasks) do
        sequence = Enum.reduce_while(tasks, 1, fn task, acc ->
            if Kernel.is_bitstring(task["name"]) do
                task_name_id = get_task_numeric_id(task["name"])

                {_, task_int_id} = if(is_numeric(task_name_id), do: {:ok, String.to_integer(task_name_id)}, else: {:halt, -1})

                if(task_int_id === acc, do: {:cont, acc + 1}, else: {:halt, -1})
            else
                {:halt, -1}
            end
        end)

        if(sequence > -1, do: {:ok, sequence}, else: {:error, "Wrong tasks sequence. Please start to increment sequentially from task-1"})
    end

    def required_tasks_are_lists(tasks) do
        result = Enum.reduce_while(tasks, 0, fn task, acc ->
            if task["requires"] && !Kernel.is_list(task["requires"]) do
                {:halt, -1}
            else
                {:cont, acc}
            end
        end)
        if result === -1, do: {:error, "All required tasks should be provided in array"}, else: {:ok, result}
    end

    def required_tasks_ids_have_valid_range(tasks) do
        valid_range = 1..length(tasks)
        is_in_range = Enum.reduce_while(tasks, valid_range, fn task, acc ->
            if Kernel.is_list(task["requires"]) do
                result = Enum.reduce_while(task["requires"], acc, fn req, acc_range ->
                            if Kernel.is_bitstring(req) do
                                task_name_id = get_task_numeric_id(req)

                                {_, task_int_id} = if(is_numeric(task_name_id), do: {:ok, String.to_integer(task_name_id)}, else: {:halt, -1})

                                if(task_int_id in acc_range, do: {:cont, acc_range}, else: {:halt, -1})
                            else
                                {:halt, -1}
                            end
                        end)
                if(result === -1, do: {:halt, -1}, else: {:cont, acc})
            else
                {:cont, acc}
            end
        end)

        if(is_in_range === -1, do: {:error, "Required tasks IDs are not valid (e.g. task-2) or out of scope"}, else: {:ok, is_in_range})
    end

    def is_numeric(str) do
        case Float.parse(str) do
            {_num, ""} -> true
            _          -> false
        end
    end

    def get_task_numeric_id(task_name_id) do
      String.split(task_name_id, "-", trim: true)|> List.last()
    end
end
