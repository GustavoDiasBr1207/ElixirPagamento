defmodule PhoenixPay.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixPayWeb.Telemetry,
      PhoenixPay.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_pay, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixPay.PubSub},
      {Oban, Application.fetch_env!(:oban)},
      PhoenixPayWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: PhoenixPay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PhoenixPayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
