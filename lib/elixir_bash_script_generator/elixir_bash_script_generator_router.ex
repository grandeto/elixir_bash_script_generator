defmodule ElixirBashScriptGenerator.Router do
    alias Middleware.Http.Validator, as: Validator
    use Plug.Router
    use Plug.Debugger
    require Logger

    plug(Plug.Logger, log: :debug)
    plug(:match)
    plug(:dispatch)

    post "/generate" do
        {:ok, body, conn} = read_body(conn)
        body = Poison.decode!(body)

        with {:ok, body} <- Validator.body_is_map(body),
            {:ok, tasks} <- Validator.tasks_is_list(body["tasks"]),
            {:ok, sequence} <- Validator.tasks_ids_are_sequence(body["tasks"]),
            {:ok, valid_required_ids_range} <- Validator.valid_required_ids_range(body["tasks"])
        do
            response = ElixirBashScriptGenerator.generate(tasks)
            conn
            |> prepend_resp_headers([{"content-type", "application/json"}])
            |> send_resp(201, Poison.encode!(response))
            |> halt()
        else
            {:error, reason} ->
            conn
            |> prepend_resp_headers([{"content-type", "application/json"}])
            |> send_resp(400, Poison.encode!(%{error: reason}))
            |> halt()
        end
    end

    match _ do
        send_resp(conn, 404, "")
    end

end
