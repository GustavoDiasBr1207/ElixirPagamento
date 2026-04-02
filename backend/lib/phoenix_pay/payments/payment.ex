defmodule PhoenixPay.Payments.Payment do
  use PhoenixPay.Schema

  schema "payments" do
    field :reference_id, :string
    field :amount, :decimal
    field :description, :string
    field :status, Ecto.Enum,
      values: [:pending, :processing, :paid, :failed, :cancelled, :refunded],
      default: :pending
    field :payment_method, Ecto.Enum, values: [:pix, :boleto, :card], default: :pix
    field :due_date, :utc_datetime_usec
    field :paid_at, :utc_datetime_usec
    field :metadata, :map, default: %{}
    field :idempotency_key, :string

    belongs_to :user, PhoenixPay.Accounts.User, type: :binary_id
    has_many :transactions, PhoenixPay.Payments.Transaction, foreign_key: :payment_id
    has_many :webhook_logs, PhoenixPay.Webhooks.WebhookLog, foreign_key: :payment_id

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :user_id,
      :reference_id,
      :amount,
      :description,
      :payment_method,
      :due_date,
      :metadata,
      :idempotency_key
    ])
    |> validate_required([:user_id, :amount, :description])
    |> validate_number(:amount, greater_than: 0)
    |> generate_reference_id()
    |> put_idempotency_key()
    |> unique_constraint(:idempotency_key)
  end

  def confirm_changeset(payment) do
    payment
    |> change(
      status: :paid,
      paid_at: DateTime.utc_now()
    )
  end

  def fail_changeset(payment) do
    change(payment, status: :failed)
  end

  defp generate_reference_id(changeset) do
    case get_field(changeset, :reference_id) do
      nil -> put_change(changeset, :reference_id, "PIX_#{UUID.uuid4() |> String.upcase()}")
      _ -> changeset
    end
  end

  defp put_idempotency_key(changeset) do
    case get_field(changeset, :idempotency_key) do
      nil -> put_change(changeset, :idempotency_key, UUID.uuid4())
      _ -> changeset
    end
  end
end
