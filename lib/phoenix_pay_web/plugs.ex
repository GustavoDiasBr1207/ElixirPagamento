defmodule PhoenixPayWeb.Plugs.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      user_id when is_binary(user_id) ->
        assign(conn, :current_user_id, user_id)

      nil ->
        conn
    end
  end
end

defmodule PhoenixPayWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user_id] do
      conn
    else
      conn
      |> put_flash(:error, "Acesso não autorizado")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end

defmodule PhoenixPayWeb.Plugs.APIAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      case verify_jwt_token(token) do
        {:ok, user_id} ->
          assign(conn, :current_user_id, user_id)

        {:error, _} ->
          conn
      end
    else
      _ -> conn
    end
  end

  defp verify_jwt_token(token) do
    case JWT.decode(token, System.get_env("JWT_SECRET", "default_secret")) do
      {:ok, payload} -> {:ok, payload["sub"]}
      _ -> {:error, :invalid_token}
    end
  end
end
