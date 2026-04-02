defmodule PhoenixPay.Accounts do
  import Ecto.Query

  alias PhoenixPay.Repo
  alias PhoenixPay.Accounts.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def authenticate(email, password) do
    case get_user_by_email(email) do
      %User{} = user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          user
          |> User.login_changeset()
          |> Repo.update()
        else
          {:error, "Credenciais inválidas"}
        end

      nil ->
        {:error, "Usuário não encontrado"}
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def list_users do
    Repo.all(User)
  end

  def count_active_users do
    Repo.aggregate(from(u in User, where: u.status == :active), :count)
  end
end
