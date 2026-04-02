defmodule PhoenixPay.Webhooks.Webhook do
  use PhoenixPay.Schema

  schema "webhooks" do
    field :url, :string
    field :events, {:array, :string}
    field :active, :boolean, default: true
    field :secret, :string
    field :retry_count, :integer, default: 0
    field :last_triggered_at, :utc_datetime_usec

    belongs_to :user, PhoenixPay.Accounts.User, type: :binary_id
    has_many :logs, PhoenixPay.Webhooks.WebhookLog, foreign_key: :webhook_id

    timestamps()
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:user_id, :url, :events, :active, :secret])
    |> validate_required([:user_id, :url, :events])
    |> validate_format(:url, ~r/^https?:\/\/.+/)
    |> generate_secret()
    |> validate_length(:events, min: 1)
  end

  defp generate_secret(%{changes: %{secret: _}} = changeset), do: changeset

  defp generate_secret(changeset) do
    put_change(changeset, :secret, SecureRandom.hex(32))
  end
end
