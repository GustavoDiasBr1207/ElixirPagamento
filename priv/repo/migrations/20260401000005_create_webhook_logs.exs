defmodule PhoenixPay.Repo.Migrations.CreateWebhookLogs do
  use Ecto.Migration

  def change do
    create table(:webhook_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :webhook_id, references(:webhooks, type: :binary_id, on_delete: :cascade), null: false
      add :payment_id, references(:payments, type: :binary_id, on_delete: :cascade)
      add :event, :string, null: false
      add :status_code, :integer
      add :response_body, :text
      add :error_message, :string
      add :attempt, :integer, default: 1
      add :success, :boolean, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:webhook_logs, [:webhook_id])
    create index(:webhook_logs, [:payment_id])
    create index(:webhook_logs, [:success])
  end
end
