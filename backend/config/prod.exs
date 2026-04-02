import Config

config :phoenix_pay, PhoenixPayWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST", "example.com"), port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise "SECRET_KEY_BASE not set"

config :logger, level: :info

# ===== SUPABASE DATABASE (Production) =====
config :phoenix_pay, PhoenixPay.Repo,
  database: System.get_env("DATABASE_NAME", "postgres"),
  username: System.get_env("DATABASE_USER", "postgres"),
  password: System.get_env("DATABASE_PASSWORD") || raise "DATABASE_PASSWORD not set",
  hostname: System.get_env("DATABASE_HOST") || raise "DATABASE_HOST not set",
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  ssl: true,
  ssl_opts: [verify: :verify_none],
  pool_size: 20,
  queue_target: 5000,
  queue_interval: 1000

# ===== JOB QUEUE (Oban) =====
# Supabase: use PostgreSQL directly (sem Redis)
config :oban,
  repo: PhoenixPay.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    payments: 20,
    webhooks: 10
  ]
