defmodule PhoenixPayWeb.PaymentsLive.Index do
  use PhoenixPayWeb, :live_view

  alias PhoenixPay.Payments

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]

    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixPay.PubSub, "payments:#{user_id}")
    end

    payments = Payments.list_user_payments(user_id)

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:payments, payments)
     |> assign(:loading, false)}
  end

  @impl true
  def handle_info({:payment_updated, payment}, socket) do
    if payment.user_id == socket.assigns.user_id do
      payments = Payments.list_user_payments(socket.assigns.user_id)
      {:noreply, assign(socket, :payments, payments)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("create_payment", %{"amount" => amount, "description" => description}, socket) do
    case Payments.create_payment(%{
      "user_id" => socket.assigns.user_id,
      "amount" => amount,
      "description" => description,
      "payment_method" => "pix"
    }) do
      {:ok, _payment} ->
        payments = Payments.list_user_payments(socket.assigns.user_id)
        {:noreply, assign(socket, :payments, payments)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen p-8">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-3xl font-bold text-gray-900 mb-8">Meus Pagamentos</h1>

        <!-- Create Payment Form -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-bold text-gray-900 mb-4">Criar Novo Pagamento</h2>
          <form phx-submit="create_payment" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <input type="number" name="amount" placeholder="Valor (R$)" step="0.01" required class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            <input type="text" name="description" placeholder="Descrição" required class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" />
            <button type="submit" class="bg-indigo-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-indigo-700 transition">
              Criar Pagamento
            </button>
          </form>
        </div>

        <!-- Payments Table -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
          <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
              <tr>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Referência</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Valor</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Descrição</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Status</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Data</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Ação</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <%= for payment <- @payments do %>
                <tr class="hover:bg-gray-50 transition">
                  <td class="px-6 py-4 text-sm text-gray-900 font-mono">
                    <%= String.slice(payment.reference_id, 0..12) %>...
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-900 font-semibold">
                    R$ <%= format_currency(payment.amount) %>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-600">
                    <%= payment.description %>
                  </td>
                  <td class="px-6 py-4 text-sm">
                    <span class={badge_class(payment.status)}>
                      <%= format_status(payment.status) %>
                    </span>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-600">
                    <%= payment.inserted_at |> format_datetime() %>
                  </td>
                  <td class="px-6 py-4 text-sm">
                    <a href={"/dashboard/payments/#{payment.id}"} class="text-indigo-600 hover:text-indigo-700 font-semibold">
                      Ver Detalhes
                    </a>
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

  defp format_currency(value) do
    value
    |> Decimal.to_float()
    |> Float.round(2)
    |> Float.to_string()
  end

  defp format_status(:pending), do: "Pendente"
  defp format_status(:processing), do: "Processando"
  defp format_status(:paid), do: "Pago"
  defp format_status(:failed), do: "Falhou"
  defp format_status(:cancelled), do: "Cancelado"
  defp format_status(:refunded), do: "Reembolsado"
  defp format_status(status), do: to_string(status)

  defp badge_class(:pending), do: "px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-semibold"
  defp badge_class(:processing), do: "px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-semibold"
  defp badge_class(:paid), do: "px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold"
  defp badge_class(:failed), do: "px-3 py-1 bg-red-100 text-red-800 rounded-full text-xs font-semibold"
  defp badge_class(:cancelled), do: "px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-xs font-semibold"
  defp badge_class(:refunded), do: "px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-xs font-semibold"
  defp badge_class(_), do: "px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-xs font-semibold"

  defp format_datetime(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%d/%m/%Y %H:%M")
  end
end
