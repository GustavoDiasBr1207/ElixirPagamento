defmodule PhoenixPay.Payments do
  import Ecto.Query

  alias PhoenixPay.Repo
  alias PhoenixPay.Payments.{Payment, Transaction}
  alias PhoenixPay.PubSub

  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change(:payment_created)
  end

  def get_payment!(id) do
    Repo.get!(Payment, id)
  end

  def get_payment_by_reference(reference_id) do
    Repo.get_by(Payment, reference_id: reference_id)
  end

  def list_user_payments(user_id) do
    Payment
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:transactions)
  end

  def list_recent_payments(limit \\ 10) do
    Payment
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def confirm_payment(%Payment{} = payment) do
    payment
    |> Payment.confirm_changeset()
    |> Repo.update()
    |> tap(fn {:ok, updated_payment} ->
      publish_payment_update(:payment_confirmed, updated_payment)
    end)
  end

  def fail_payment(%Payment{} = payment) do
    payment
    |> Payment.fail_changeset()
    |> Repo.update()
    |> broadcast_change(:payment_failed)
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def confirm_transaction(%Transaction{} = transaction, external_id) do
    transaction
    |> Transaction.success_changeset(external_id)
    |> Repo.update()
  end

  def fail_transaction(%Transaction{} = transaction, error_message) do
    transaction
    |> Transaction.failed_changeset(error_message)
    |> Repo.update()
  end

  def list_user_transactions(user_id) do
    Transaction
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_payment_stats(user_id) do
    Payment
    |> where(user_id: ^user_id)
    |> select([p], %{
      total_amount: sum(p.amount),
      paid_amount: sum(fragment("CASE WHEN status = ? THEN amount ELSE 0 END", "paid")),
      pending_count: count(fragment("CASE WHEN status = ? THEN 1 END", "pending")),
      paid_count: count(fragment("CASE WHEN status = ? THEN 1 END", "paid")),
      total_count: count(p.id)
    })
    |> Repo.one()
  end

  def get_dashboard_stats do
    %{
      total_payments: counted_payments(),
      total_volume: total_volume(),
      paid_volume: paid_volume(),
      pending_payments: pending_payments(),
      conversion_rate: conversion_rate()
    }
  end

  defp counted_payments do
    Repo.aggregate(Payment, :count, :id)
  end

  defp total_volume do
    Payment
    |> select([p], sum(p.amount))
    |> Repo.one() || Decimal.new(0)
  end

  defp paid_volume do
    Payment
    |> where(status: :paid)
    |> select([p], sum(p.amount))
    |> Repo.one() || Decimal.new(0)
  end

  defp pending_payments do
    Payment
    |> where(status: :pending)
    |> Repo.aggregate(:count, :id)
  end

  defp conversion_rate do
    total = counted_payments()

    if total == 0 do
      0.0
    else
      paid = Repo.aggregate(where(Payment, status: :paid), :count, :id)
      (paid / total) * 100
    end
  end

  defp broadcast_change({:ok, payment}), do: publish_payment_update(payment)
  defp broadcast_change({:error, _} = error), do: error

  defp publish_payment_update(payment) do
    Phoenix.PubSub.broadcast(
      PhoenixPay.PubSub,
      "payments:#{payment.user_id}",
      {:payment_updated, payment}
    )

    {:ok, payment}
  end

  defp publish_payment_update(event, payment) do
    Phoenix.PubSub.broadcast(
      PhoenixPay.PubSub,
      "payments:#{payment.user_id}",
      {event, payment}
    )
  end
end
