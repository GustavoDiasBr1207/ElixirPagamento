defmodule PhoenixPayWeb.API.PaymentController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Payments

  def index(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    payments = Payments.list_user_payments(user_id)

    conn
    |> put_status(:ok)
    |> json(%{
      payments: Enum.map(payments, &format_payment/1)
    })
  end

  def create(conn, %{"amount" => amount, "description" => description} = params) do
    user_id = conn.assigns[:current_user_id]

    attrs = %{
      "user_id" => user_id,
      "amount" => amount,
      "description" => description,
      "payment_method" => params["payment_method"] || "pix",
      "metadata" => params["metadata"] || %{}
    }

    case Payments.create_payment(attrs) do
      {:ok, payment} ->
        conn
        |> put_status(:created)
        |> json(%{
          payment_id: payment.id,
          reference_id: payment.reference_id,
          amount: payment.amount,
          status: payment.status,
          created_at: payment.inserted_at
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => payment_id}) do
    user_id = conn.assigns[:current_user_id]

    case Payments.get_payment!(payment_id) do
      %{user_id: ^user_id} = payment ->
        conn
        |> put_status(:ok)
        |> json(format_payment(payment))

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Pagamento não encontrado"})
    end
  end

  def confirm(conn, %{"id" => payment_id}) do
    user_id = conn.assigns[:current_user_id]

    case Payments.get_payment!(payment_id) do
      %{user_id: ^user_id} = payment ->
        case Payments.confirm_payment(payment) do
          {:ok, updated_payment} ->
            # Dispara worker para processar webhooks
            PhoenixPayWeb.Workers.PaymentConfirmationWorker.enqueue(updated_payment.id)

            conn
            |> put_status(:ok)
            |> json(%{
              payment_id: updated_payment.id,
              status: updated_payment.status,
              paid_at: updated_payment.paid_at
            })

          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Erro ao confirmar pagamento"})
        end

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Pagamento não encontrado"})
    end
  end

  def status(conn, %{"id" => payment_id}) do
    user_id = conn.assigns[:current_user_id]

    case Payments.get_payment!(payment_id) do
      %{user_id: ^user_id} = payment ->
        conn
        |> put_status(:ok)
        |> json(%{
          payment_id: payment.id,
          status: payment.status,
          amount: payment.amount,
          paid_at: payment.paid_at
        })

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Pagamento não encontrado"})
    end
  end

  defp format_payment(payment) do
    %{
      id: payment.id,
      reference_id: payment.reference_id,
      amount: payment.amount,
      description: payment.description,
      status: payment.status,
      payment_method: payment.payment_method,
      created_at: payment.inserted_at,
      paid_at: payment.paid_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
