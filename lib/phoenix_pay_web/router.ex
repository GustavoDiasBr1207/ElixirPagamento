defmodule PhoenixPayWeb.Router do
  use PhoenixPayWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoenixPayWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PhoenixPayWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origins: "*"
    plug PhoenixPayWeb.Plugs.APIAuth
  end

  pipeline :auth do
    plug PhoenixPayWeb.Plugs.RequireAuth
  end

  scope "/", PhoenixPayWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", AuthController, :login
    post "/login", AuthController, :create_session
    get "/logout", AuthController, :logout
    post "/register", AuthController, :register
  end

  scope "/dashboard", PhoenixPayWeb do
    pipe_through [:browser, :auth]

    live "/", DashboardLive.Index, :index
    live "/payments", PaymentsLive.Index, :index
    live "/payments/:id", PaymentsLive.Show, :show
    live "/webhooks", WebhooksLive.Index, :index
  end

  scope "/api/v1", PhoenixPayWeb.API do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api/v1", PhoenixPayWeb.API do
    pipe_through [:api, :auth]

    # Payments
    get "/payments", PaymentController, :index
    post "/payments", PaymentController, :create
    get "/payments/:id", PaymentController, :show
    post "/payments/:id/confirm", PaymentController, :confirm
    get "/payments/:id/status", PaymentController, :status

    # Transactions
    get "/transactions", TransactionController, :index
    get "/transactions/:id", TransactionController, :show

    # Webhooks
    get "/webhooks", WebhookController, :index
    post "/webhooks", WebhookController, :create
    put "/webhooks/:id", WebhookController, :update
    delete "/webhooks/:id", WebhookController, :delete
    get "/webhooks/:id/logs", WebhookController, :logs

    # Stats
    get "/stats", StatsController, :index
    get "/stats/user", StatsController, :user_stats
  end

  scope "/webhooks", PhoenixPayWeb do
    pipe_through :api
    post "/:token/events", WebhookController, :receive_event
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PhoenixPayWeb.Telemetry
    end
  end
end
