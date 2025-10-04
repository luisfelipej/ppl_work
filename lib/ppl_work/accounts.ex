defmodule PplWork.Accounts do
  @moduledoc """
  The Accounts context manages user authentication and registration.
  """

  import Ecto.Query, warn: false
  alias PplWork.Repo
  alias PplWork.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user by id.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("john_doe")
      %User{}

      iex> get_user_by_username("unknown_user")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Registers a new user.

  ## Examples

      iex> register_user(%{email: "user@example.com", username: "john", password: "Password123"})
      {:ok, %User{}}

      iex> register_user(%{email: "bad-email", username: "a", password: "short"})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{email: "newemail@example.com"})
      {:ok, %User{}}

      iex> update_user(user, %{email: "invalid"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user by email and password.

  ## Examples

      iex> authenticate_user("user@example.com", "correct_password")
      {:ok, %User{}}

      iex> authenticate_user("user@example.com", "wrong_password")
      {:error, :invalid_credentials}

  """
  def authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)

    cond do
      user && User.valid_password?(user, password) ->
        {:ok, user}

      user ->
        {:error, :invalid_credentials}

      true ->
        # Run a dummy hash to prevent timing attacks
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user registration.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end
end
