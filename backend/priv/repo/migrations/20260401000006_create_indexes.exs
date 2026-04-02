defmodule PhoenixPay.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create index(:payments, [:payment_method])
    create index(:transactions, [:type])
  end
end
