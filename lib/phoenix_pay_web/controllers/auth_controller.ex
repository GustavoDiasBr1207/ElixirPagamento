defmodule PhoenixPayWeb.AuthController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Accounts

  def login(conn, _params) do
    render(conn, :login)
  end

  def create_session(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Bem-vindo!")
        |> redirect(to: "/dashboard")

      {:error, _} ->
        conn
        |> put_flash(:error, "Email ou senha inválidos")
        |> redirect(to: "/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end

  def register(conn, %{"email" => email, "name" => name, "password" => password}) do
    case Accounts.create_user(%{email: email, name: name, password: password}) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Conta criada com sucesso!")
        |> redirect(to: "/dashboard")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro ao criar conta")
        |> redirect(to: "/login")
    end
  end
end
