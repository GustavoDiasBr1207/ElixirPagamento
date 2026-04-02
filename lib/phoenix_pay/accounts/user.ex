defmodule PhoenixPay.Accounts.User do
  use PhoenixPay.Schema

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :cpf, :string
    field :phone, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :suspended], default: :active
    field :last_login_at, :utc_datetime_usec

    has_many :payments, PhoenixPay.Payments.Payment, foreign_key: :user_id
    has_many :transactions, PhoenixPay.Payments.Transaction, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :cpf, :phone, :status])
    |> validate_required([:email, :name, :password])
    |> validate_email()
    |> validate_length(:name, min: 3, max: 100)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :cpf, :phone, :status])
    |> validate_length(:name, min: 3, max: 100)
  end

  def login_changeset(user) do
    user
    |> change(last_login_at: DateTime.utc_now())
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Email inválido")
  end

  defp put_password_hash(%{changes: %{password: password}} = changeset) when is_binary(password) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
