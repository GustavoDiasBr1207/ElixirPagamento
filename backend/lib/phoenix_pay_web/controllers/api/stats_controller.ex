defmodule PhoenixPayWeb.API.StatsController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Payments

  def index(conn, _params) do
    stats = Payments.get_dashboard_stats()

    conn
    |> put_status(:ok)
    |> json(stats)
  end

  def user_stats(conn, _params) do
    user_id = conn.assigns[:current_user_id]
    stats = Payments.get_payment_stats(user_id)

    conn
    |> put_status(:ok)
    |> json(stats || %{})
  end
end
