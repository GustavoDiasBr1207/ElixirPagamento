defmodule PhoenixPayWeb.API.TransactionController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Payments

  def index(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    transactions = Payments.list_user_transactions(user_id)

    conn
    |> put_status(:ok)
    |> json(%{
      transactions: Enum.map(transactions, &format_transaction/1)
    })
  end

  def show(conn, %{"id" => transaction_id}) do
    user_id = conn.assigns[:current_user_id]

    case Payments.Repo.get(Payments.Transaction, transaction_id) do
      %{user_id: ^user_id} = transaction ->
        conn
        |> put_status(:ok)
        |> json(format_transaction(transaction))

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Transação não encontrada"})
    end
  end

  defp format_transaction(transaction) do
    %{
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      status: transaction.status,
      created_at: transaction.inserted_at
    }
  end
end
