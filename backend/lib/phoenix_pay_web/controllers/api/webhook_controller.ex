defmodule PhoenixPayWeb.API.WebhookController do
  use PhoenixPayWeb, :controller

  alias PhoenixPay.Webhooks

  def index(conn, _params) do
    user_id = conn.assigns[:current_user_id]
    webhooks = Webhooks.list_user_webhooks(user_id)

    conn
    |> put_status(:ok)
    |> json(%{
      webhooks: Enum.map(webhooks, &format_webhook/1)
    })
  end

  def create(conn, %{"url" => url, "events" => events}) do
    user_id = conn.assigns[:current_user_id]

    case Webhooks.create_webhook(%{
      "user_id" => user_id,
      "url" => url,
      "events" => events
    }) do
      {:ok, webhook} ->
        conn
        |> put_status(:created)
        |> json(format_webhook(webhook))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => webhook_id} = params) do
    user_id = conn.assigns[:current_user_id]

    case Webhooks.get_webhook!(webhook_id) do
      %{user_id: ^user_id} = webhook ->
        case Webhooks.update_webhook(webhook, params) do
          {:ok, updated} ->
            conn
            |> put_status(:ok)
            |> json(format_webhook(updated))

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: format_errors(changeset)})
        end

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Webhook não encontrado"})
    end
  end

  def delete(conn, %{"id" => webhook_id}) do
    user_id = conn.assigns[:current_user_id]

    case Webhooks.get_webhook!(webhook_id) do
      %{user_id: ^user_id} = webhook ->
        case Webhooks.delete_webhook(webhook) do
          {:ok, _} ->
            conn
            |> put_status(:no_content)
            |> json(%{})

          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Erro ao deletar webhook"})
        end

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Webhook não encontrado"})
    end
  end

  def logs(conn, %{"id" => webhook_id}) do
    user_id = conn.assigns[:current_user_id]

    case Webhooks.get_webhook!(webhook_id) do
      %{user_id: ^user_id} ->
        logs = Webhooks.list_webhook_logs(webhook_id)

        conn
        |> put_status(:ok)
        |> json(%{
          logs: Enum.map(logs, &format_log/1)
        })

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Webhook não encontrado"})
    end
  end

  defp format_webhook(webhook) do
    %{
      id: webhook.id,
      url: webhook.url,
      events: webhook.events,
      active: webhook.active,
      created_at: webhook.inserted_at
    }
  end

  defp format_log(log) do
    %{
      id: log.id,
      event: log.event,
      status_code: log.status_code,
      success: log.success,
      attempt: log.attempt,
      created_at: log.inserted_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
