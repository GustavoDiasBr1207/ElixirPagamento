defmodule PhoenixPay.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :cascade), null: false
      add :payment_id, references(:payments, type: :binary_id, on_delete: :cascade)
      add :type, :string, null: false
      add :amount, :decimal, null: false, precision: 19, scale: 4
      add :description, :string
      add :status, :string, default: "pending", null: false
      add :external_id, :string
      add :error_message, :string
      add :metadata, :map, default: %{}, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:transactions, [:user_id])
    create index(:transactions, [:payment_id])
    create index(:transactions, [:status])
  end
end
