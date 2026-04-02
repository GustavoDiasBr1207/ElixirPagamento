defmodule PhoenixPayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_pay

  socket "/socket", PhoenixPayWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :phoenix_pay,
    gzip: false,
    only: PhoenixPayWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
  end

  plug Phoenix.CodeReloader, backends: [Phoenix.CodeReloader.EEx]

  plug CORSPlug, origins: "*"

  plug Plug.RequestId
  plug Plug.Telemetry, event_name: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug PhoenixPayWeb.Router
end
