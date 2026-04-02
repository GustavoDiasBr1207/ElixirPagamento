defmodule PhoenixPayWeb.Workers.WebhookDispatchWorker do
  use Oban.Worker, queue: :webhooks, max_attempts: 5

  require Logger

  alias PhoenixPay.{Webhooks, Payments}

  def enqueue(payment_id, event) do
    %{payment_id: payment_id, event: event}
    |> new()
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"payment_id" => payment_id, "event" => event}} = job) do
    payment = Payments.get_payment!(payment_id)
    webhooks = Webhooks.find_webhooks_for_event(payment.user_id, event)

    results =
      Enum.map(webhooks, fn webhook ->
        dispatch_webhook(webhook, payment, event, job.attempt)
      end)

    if Enum.all?(results, fn r -> r == :ok end) do
      :ok
    else
      {:reschedule, 60}
    end
  end

  defp dispatch_webhook(webhook, payment, event, attempt) do
    payload = %{
      id: payment.id,
      reference_id: payment.reference_id,
      amount: payment.amount,
      status: payment.status,
      event: event,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    signature = generate_signature(webhook.secret, Jason.encode!(payload))

    headers = [
      {"Content-Type", "application/json"},
      {"X-Webhook-Signature", signature},
      {"X-Webhook-Event", event},
      {"X-Webhook-Attempt", to_string(attempt)}
    ]

    case HTTPoison.post(webhook.url, Jason.encode!(payload), headers, timeout: 10_000) do
      {:ok, response} ->
        log_webhook_attempt(webhook, payment, event, attempt, response.status_code, :ok)
        :ok

      {:error, reason} ->
        log_webhook_attempt(webhook, payment, event, attempt, nil, :error, to_string(reason))
        :error
    end
  end

  defp generate_signature(secret, payload) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end

  defp log_webhook_attempt(webhook, payment, event, attempt, status_code, result, error_msg \\ nil) do
    Webhooks.create_webhook_log(%{
      "webhook_id" => webhook.id,
      "payment_id" => payment.id,
      "event" => event,
      "status_code" => status_code,
      "attempt" => attempt,
      "success" => result == :ok,
      "error_message" => error_msg
    })
  end
end
