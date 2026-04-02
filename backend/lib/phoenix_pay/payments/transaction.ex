defmodule PhoenixPay.Payments.Transaction do
  use PhoenixPay.Schema

  schema "transactions" do
    field :type, Ecto.Enum, values: [:debit, :credit, :transfer, :refund], default: :debit
    field :amount, :decimal
    field :description, :string
    field :status, Ecto.Enum, values: [:success, :pending, :failed], default: :pending
    field :external_id, :string
    field :error_message, :string
    field :metadata, :map, default: %{}

    belongs_to :user, PhoenixPay.Accounts.User, type: :binary_id
    belongs_to :payment, PhoenixPay.Payments.Payment, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:user_id, :payment_id, :type, :amount, :description, :metadata])
    |> validate_required([:user_id, :type, :amount])
    |> validate_number(:amount, greater_than: 0)
  end

  def success_changeset(transaction, external_id) do
    transaction
    |> change(status: :success, external_id: external_id)
  end

  def failed_changeset(transaction, error_message) do
    transaction
    |> change(status: :failed, error_message: error_message)
  end
end
