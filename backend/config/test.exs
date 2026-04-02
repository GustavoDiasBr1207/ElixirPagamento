import Config

config :phoenix_pay, PhoenixPay.Repo,
  username: "postgres",
  password: "postgres",
  database: "phoenix_pay_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :phoenix_pay, PhoenixPayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_for_testing_only",
  server: false

config :logger, level: :warning

config :pbkdf2_elixir, rounds: 1
