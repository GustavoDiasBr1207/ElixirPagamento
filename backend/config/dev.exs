import Config

config :phoenix_pay, PhoenixPayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_for_development_only",
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phoenix_pay_web/(controllers|live|components)/.+\.ex$"
    ]
  ]

# ===== SUPABASE DATABASE (Development) =====
# Usar variáveis de ambiente ou valores locais para testes
config :phoenix_pay, PhoenixPay.Repo,
  database: System.get_env("DATABASE_NAME", "postgres"),
  username: System.get_env("DATABASE_USER", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", ""),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  ssl: String.to_atom(System.get_env("DATABASE_SSL", "false")),
  pool_size: 5

config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
