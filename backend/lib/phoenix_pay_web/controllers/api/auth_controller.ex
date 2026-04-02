defmodule PhoenixPayWeb.API.AuthController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Accounts

  def register(conn, %{"email" => email, "name" => name, "password" => password}) do
    case Accounts.create_user(%{"email" => email, "name" => name, "password" => password}) do
      {:ok, user} ->
        token = generate_jwt_token(user.id)

        conn
        |> put_status(:created)
        |> json(%{
          user_id: user.id,
          email: user.email,
          name: user.name,
          token: token
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate(email, password) do
      {:ok, user} ->
        token = generate_jwt_token(user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          user_id: user.id,
          email: user.email,
          name: user.name,
          token: token
        })

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: message})
    end
  end

  defp generate_jwt_token(user_id) do
    secret = System.get_env("JWT_SECRET", "default_secret")
    
    case Joken.encode(%{"sub" => user_id}, secret) do
      {:ok, token} -> token
      {:error, _} -> nil
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
