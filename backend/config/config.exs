import Config

# ===== DATABASE CONFIGURATION (Supabase PostgreSQL) =====
config :phoenix_pay, PhoenixPay.Repo,
  database: "postgres",
  username: "postgres",
  password: System.get_env("DATABASE_PASSWORD", ""),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  ssl: String.to_atom(System.get_env("DATABASE_SSL", "true")),
  ssl_opts: [verify: :verify_none],  # Supabase SSL cert
  pool_size: 10,
  queue_target: 5000,
  queue_interval: 1000

config :phoenix_pay, PhoenixPayWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: PhoenixPayWeb.ErrorJSON, html: PhoenixPayWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: PhoenixPay.PubSub,
  live_view: [signing_salt: "phoenix_pay_salt"]

config :logger, :console,
  format: "[$level] $message\n",
  metadata: [:request_id, :user_id]

config :esbuild,
  version: "0.17.11",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :gettext, :default_locale, "pt_BR"

config :oban,
  repo: PhoenixPay.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    payments: 20,
    webhooks: 10
  ]

import_config "#{Mix.env()}.exs"
