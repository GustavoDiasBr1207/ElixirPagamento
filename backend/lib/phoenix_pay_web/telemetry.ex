defmodule PhoenixPayWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, telemetry_poller_metrics: telemetry_poller_metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp telemetry_poller_metrics do
    [
      {PhoenixPay.Repo, [:phoenix_pay, :repo, :query_time],
       unit: {:native, :millisecond}},
      {:process_info, [:phoenix_pay, :vm, :memory],
       memory: :memory,
       total: :total}
    ]
  end
end
