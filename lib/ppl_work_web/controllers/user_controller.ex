defmodule PplWorkWeb.UserController do
  use PplWorkWeb, :controller

  alias PplWork.Accounts
  alias PplWork.Accounts.User

  action_fallback PplWorkWeb.FallbackController

  @doc """
  POST /api/users/register
  Register a new user
  """
  def register(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  @doc """
  POST /api/users/login
  Authenticate a user
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render(:show, user: user)

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  @doc """
  GET /api/users/:id
  Get user by ID
  """
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end
end
