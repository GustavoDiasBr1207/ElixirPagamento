defmodule PhoenixPay.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :cascade), null: false
      add :reference_id, :string, null: false
      add :amount, :decimal, null: false, precision: 19, scale: 4
      add :description, :string, null: false
      add :status, :string, default: "pending", null: false
      add :payment_method, :string, default: "pix", null: false
      add :due_date, :utc_datetime_usec
      add :paid_at, :utc_datetime_usec
      add :idempotency_key, :string
      add :metadata, :map, default: %{}, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:payments, [:user_id])
    create index(:payments, [:status])
    create index(:payments, [:reference_id])
    create unique_index(:payments, [:idempotency_key])
  end
end
