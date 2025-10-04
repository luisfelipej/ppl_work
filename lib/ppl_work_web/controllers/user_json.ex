defmodule PplWorkWeb.UserJSON do
  alias PplWork.Accounts.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      username: user.username,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
