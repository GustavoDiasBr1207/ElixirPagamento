defmodule PhoenixPayWeb.DashboardLive.Index do
  use PhoenixPayWeb, :live_view

  alias PhoenixPay.Payments

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]

    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixPay.PubSub, "payments:#{user_id}")
    end

    stats = Payments.get_dashboard_stats()
    user_stats = Payments.get_payment_stats(user_id)

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:stats, stats)
     |> assign(:user_stats, user_stats || %{})
     |> assign(:loading, false)}
  end

  @impl true
  def handle_info({:payment_updated, _payment}, socket) do
    stats = Payments.get_dashboard_stats()
    user_stats = Payments.get_payment_stats(socket.assigns.user_id)

    {:noreply,
     socket
     |> assign(:stats, stats)
     |> assign(:user_stats, user_stats || %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen p-8">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <h1 class="text-4xl font-bold text-gray-900 mb-2">PhoenixPay Dashboard</h1>
          <p class="text-gray-600">Bem-vindo ao seu painel de controle de pagamentos em tempo real</p>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <!-- Total Payments -->
          <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-500 text-sm font-medium">Total de Pagamentos</p>
                <p class="text-3xl font-bold text-gray-900 mt-2">
                  <%= @stats.total_payments %>
                </p>
              </div>
              <div class="bg-blue-100 p-3 rounded-full">
                <svg class="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z" />
                  <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z" />
                </svg>
              </div>
            </div>
          </div>

          <!-- Pending Payments -->
          <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-500 text-sm font-medium">Pendentes</p>
                <p class="text-3xl font-bold text-yellow-600 mt-2">
                  <%= @stats.pending_payments %>
                </p>
              </div>
              <div class="bg-yellow-100 p-3 rounded-full">
                <svg class="w-6 h-6 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M13.477 14.89A6 6 0 15 2.05 3.05a6 6 0 0 1 11.44 9.84M9.368 9.75a.75.75 0 1 0-1.736 0 .75.75 0 0 0 1.736 0z" clip-rule="evenodd" />
                </svg>
              </div>
            </div>
          </div>

          <!-- Total Volume -->
          <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-500 text-sm font-medium">Volume Total</p>
                <p class="text-3xl font-bold text-gray-900 mt-2">
                  R$ <%= format_currency(@stats.total_volume) %>
                </p>
              </div>
              <div class="bg-green-100 p-3 rounded-full">
                <svg class="w-6 h-6 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M8.16 5.314l4.897-1.596A1 1 0 0 1 14.371 4.5l.5 5a1 1 0 0 1-.96 1.079l-.5.05a1 1 0 0 1-.979-.949l-.348-3.476-4.897 1.596a1 1 0 1 1-.646-1.906zM1 11a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1v-3z" />
                </svg>
              </div>
            </div>
          </div>

          <!-- Conversion Rate -->
          <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-500 text-sm font-medium">Taxa de Conversão</p>
                <p class="text-3xl font-bold text-purple-600 mt-2">
                  <%= format_percentage(@stats.conversion_rate) %>
                </p>
              </div>
              <div class="bg-purple-100 p-3 rounded-full">
                <svg class="w-6 h-6 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M2 11a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1v-5zM8 7a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V7zM14 4a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1V4z" />
                </svg>
              </div>
            </div>
          </div>
        </div>

        <!-- User Stats -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-bold text-gray-900 mb-4">Seus Pagamentos</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-indigo-50 p-4 rounded">
              <p class="text-gray-600 text-sm">Total</p>
              <p class="text-2xl font-bold text-indigo-600">
                R$ <%= format_currency(@user_stats[:total_amount]) %>
              </p>
            </div>
            <div class="bg-green-50 p-4 rounded">
              <p class="text-gray-600 text-sm">Recebido</p>
              <p class="text-2xl font-bold text-green-600">
                R$ <%= format_currency(@user_stats[:paid_amount]) %>
              </p>
            </div>
            <div class="bg-blue-50 p-4 rounded">
              <p class="text-gray-600 text-sm">Confirmados</p>
              <p class="text-2xl font-bold text-blue-600">
                <%= @user_stats[:paid_count] || 0 %>
              </p>
            </div>
            <div class="bg-yellow-50 p-4 rounded">
              <p class="text-gray-600 text-sm">Pendentes</p>
              <p class="text-2xl font-bold text-yellow-600">
                <%= @user_stats[:pending_count] || 0 %>
              </p>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-4 justify-center">
          <a href="/dashboard/payments" class="bg-indigo-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-indigo-700 transition">
            Ver Pagamentos
          </a>
          <a href="/dashboard/webhooks" class="bg-gray-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-gray-700 transition">
            Gerenciar Webhooks
          </a>
        </div>
      </div>
    </div>
    """
  end

  defp format_currency(value) when is_nil(value), do: "0.00"

  defp format_currency(value) do
    value
    |> Decimal.to_float()
    |> Float.round(2)
    |> Float.to_string()
  end

  defp format_percentage(value) do
    value
    |> Float.round(2)
    |> then(&"#{&1}%")
  end
end
