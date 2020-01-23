defmodule ElixirBashScriptGenerator.Router do
    use Plug.Router
    use Plug.Debugger
    require Logger

    plug(Plug.Logger, log: :debug)
    plug(:match)
    plug(:dispatch)

    post "/generate" do
        {:ok, body, conn} = read_body(conn)
        body = Poison.decode!(body)
        ElixirBashScriptGenerator.generate(body)
        send_resp(conn, 201, "created: #{get_in(body, ["message"])}")
    end

    match _ do
        send_resp(conn, 404, "not found")
    end

end
