defmodule Middleware.Http.Validator do
    def is_map(data) do
        if Kernel.is_map(data) do
            {:ok, data}
        else
            {:error, "Wrong data format"}
        end
    end

    def is_list(data) do
        if Kernel.is_list(data) do
            {:ok, data}
        else
            {:error, "Wrong data format"}
        end
    end

    def tasks_are_sequence(tasks) do
        sequence = Enum.reduce(tasks, 0, fn task, result ->
            if result < 0 do
                result = -1
            end

            if Kernel.is_bitstring(task["name"]) do
                task_id = String.split(task["name"], "-", trim: true)|> List.last()
                task_id = if(is_numeric(task_id), do: String.to_integer(task_id), else: -1)
                IO.inspect(task_id)
                result = if(task_id == (result + 1), do: result + 1, else: -1)
            end
        end)

        if sequence > 0 do
            {:ok, sequence}
        else
            {:error, "Wrong tasks sequence. Please start to increment sequentially from task-1"}
        end
    end

    def is_numeric(str) do
        case Float.parse(str) do
            {_num, ""} -> true
            _          -> false
        end
    end
end
