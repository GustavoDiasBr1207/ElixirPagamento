defmodule PhoenixPayWeb.Workers.PaymentSimulationWorker do
  use Oban.Worker, queue: :payments, max_attempts: 3

  alias PhoenixPay.Payments
  alias PhoenixPayWeb.Workers.WebhookDispatchWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"payment_id" => payment_id}}) do
    payment = Payments.get_payment!(payment_id)

    # Simula delay de processamento
    Process.sleep(Enum.random(2000..5000))

    # Confirma pagamento com 95% de chance de sucesso
    if :rand.uniform() < 0.95 do
      case Payments.confirm_payment(payment) do
        {:ok, updated_payment} ->
          # Cria transação
          {:ok, _transaction} =
            Payments.create_transaction(%{
              "user_id" => updated_payment.user_id,
              "payment_id" => updated_payment.id,
              "type" => "credit",
              "amount" => updated_payment.amount,
              "description" => "Pagamento confirmado",
              "metadata" => %{
                "payment_reference" => updated_payment.reference_id,
                "payment_method" => updated_payment.payment_method
              }
            })

          # Dispara webhook
          WebhookDispatchWorker.enqueue(
            updated_payment.id,
            "payment.confirmed"
          )

          :ok

        {:error, _} ->
          {:error, "Falha ao confirmar pagamento"}
      end
    else
      # Falha
      case Payments.fail_payment(payment) do
        {:ok, _} ->
          WebhookDispatchWorker.enqueue(
            payment.id,
            "payment.failed"
          )

          :ok

        {:error, _} ->
          {:error, "Falha ao marcar pagamento como falho"}
      end
    end
  end
end

defmodule PhoenixPayWeb.Workers.PaymentConfirmationWorker do
  use Oban.Worker, queue: :payments, max_attempts: 1

  alias PhoenixPayWeb.Workers.PaymentSimulationWorker

  def enqueue(payment_id) do
    %{payment_id: payment_id}
    |> PaymentSimulationWorker.new(scheduled_in: Enum.random(1..3))
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
