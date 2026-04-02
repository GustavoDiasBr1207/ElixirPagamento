defmodule PhoenixPayWeb.WebhooksLive.Index do
  use PhoenixPayWeb, :live_view

  alias PhoenixPay.Webhooks

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]

    webhooks = Webhooks.list_user_webhooks(user_id)

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:webhooks, webhooks)
     |> assign(:loading, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen p-8">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-3xl font-bold text-gray-900 mb-8">Gerenciar Webhooks</h1>

        <div class="bg-white rounded-lg shadow-md overflow-hidden">
          <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
              <tr>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">URL</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Eventos</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Status</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Ação</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <%= for webhook <- @webhooks do %>
                <tr class="hover:bg-gray-50">
                  <td class="px-6 py-4 text-sm text-gray-900">
                    <%= webhook.url %>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-600">
                    <%= Enum.join(webhook.events, ", ") %>
                  </td>
                  <td class="px-6 py-4 text-sm">
                    <%= if webhook.active do %>
                      <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold">Ativo</span>
                    <% else %>
                      <span class="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-xs font-semibold">Inativo</span>
                    <% end %>
                  </td>
                  <td class="px-6 py-4 text-sm">
                    <a href="#" class="text-indigo-600 hover:text-indigo-700">Detalhes</a>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
