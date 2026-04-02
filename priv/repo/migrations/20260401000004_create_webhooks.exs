defmodule PhoenixPay.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :cascade), null: false
      add :url, :string, null: false
      add :events, {:array, :string}, null: false
      add :active, :boolean, default: true, null: false
      add :secret, :string, null: false
      add :retry_count, :integer, default: 0
      add :last_triggered_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:webhooks, [:user_id])
    create index(:webhooks, [:active])
  end
end
