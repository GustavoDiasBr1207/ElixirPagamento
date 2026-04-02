defmodule PhoenixPay.Webhooks do
  import Ecto.Query

  alias PhoenixPay.Repo
  alias PhoenixPay.Webhooks.{Webhook, WebhookLog}

  def create_webhook(attrs \\ %{}) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  def get_webhook!(id) do
    Repo.get!(Webhook, id)
  end

  def list_user_webhooks(user_id) do
    Webhook
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def update_webhook(%Webhook{} = webhook, attrs) do
    webhook
    |> Webhook.changeset(attrs)
    |> Repo.update()
  end

  def delete_webhook(%Webhook{} = webhook) do
    Repo.delete(webhook)
  end

  def create_webhook_log(attrs \\ %{}) do
    %WebhookLog{}
    |> WebhookLog.changeset(attrs)
    |> Repo.insert()
  end

  def list_webhook_logs(webhook_id, limit \\ 50) do
    WebhookLog
    |> where(webhook_id: ^webhook_id)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def find_webhooks_for_event(user_id, event) do
    Webhook
    |> where(user_id: ^user_id, active: true)
    |> where([w], fragment("? @> ?", w.events, ^[event]))
    |> Repo.all()
  end
end
