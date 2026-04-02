defmodule PhoenixPay.Webhooks.WebhookLog do
  use PhoenixPay.Schema

  schema "webhook_logs" do
    field :event, :string
    field :status_code, :integer
    field :response_body, :string
    field :error_message, :string
    field :attempt, :integer, default: 1
    field :success, :boolean, default: false

    belongs_to :webhook, PhoenixPay.Webhooks.Webhook, type: :binary_id
    belongs_to :payment, PhoenixPay.Payments.Payment, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :webhook_id,
      :payment_id,
      :event,
      :status_code,
      :response_body,
      :error_message,
      :attempt,
      :success
    ])
    |> validate_required([:webhook_id, :event])
  end
end
