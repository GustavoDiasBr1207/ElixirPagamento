# Manual seed file for demo/test data
# Run with: mix run priv/repo/seeds.exs

alias PhoenixPay.{Repo, Accounts, Payments, Webhooks}

# Clean existing data (optional)
# Repo.delete_all(Accounts.User)

# Create demo user
demo_user_attrs = %{
  email: "demo@phoenixpay.com",
  name: "Usuário Demo",
  password: "senha123456",
  cpf: "123.456.789-00",
  phone: "11999999999"
}

{:ok, user} = Accounts.create_user(demo_user_attrs)
IO.puts("✓ Usuário criado: #{user.email}")

# Create sample payments
1..5
|> Enum.each(fn i ->
  {:ok, payment} =
    Payments.create_payment(%{
      "user_id" => user.id,
      "amount" => Decimal.new("#{100 + i * 50}.00"),
      "description" => "Pagamento #{i}",
      "payment_method" => Enum.random([:pix, :boleto, :card])
    })

  IO.puts("✓ Pagamento #{i} criado: #{payment.reference_id}")
end)

# Create demo webhook
{:ok, webhook} =
  Webhooks.create_webhook(%{
    "user_id" => user.id,
    "url" => "https://webhook.site/unique-id",
    "events" => ["payment.confirmed", "payment.failed"]
  })

IO.puts("✓ Webhook criado: #{webhook.url}")
IO.puts("\n✅ Dados de demo carregados com sucesso!")
