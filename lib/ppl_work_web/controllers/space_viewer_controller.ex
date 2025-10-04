defmodule PplWorkWeb.SpaceViewerController do
  use PplWorkWeb, :controller

  alias PplWork.{Spaces, Accounts}

  def show(conn, %{"id" => space_id}) do
    # For MVP, we'll get user_id from query params
    # In production, this would come from session/authentication
    user_id = Map.get(conn.params, "user_id", "1")

    with {:ok, space} <- get_space(space_id),
         {:ok, user} <- get_user(user_id) do
      # Calculate initial position at center of space
      initial_position = %{
        x: (space.width / 2) |> Float.round(2),
        y: (space.height / 2) |> Float.round(2)
      }

      render(conn, :show,
        space: space,
        user: user,
        initial_position: initial_position
      )
    else
      {:error, :space_not_found} ->
        conn
        |> put_flash(:error, "Space not found")
        |> redirect(to: "/")

      {:error, :user_not_found} ->
        conn
        |> put_flash(:error, "User not found")
        |> redirect(to: "/")
    end
  end

  defp get_space(space_id) do
    try do
      space = Spaces.get_space!(String.to_integer(space_id))
      {:ok, space}
    rescue
      Ecto.NoResultsError -> {:error, :space_not_found}
      ArgumentError -> {:error, :space_not_found}
    end
  end

  defp get_user(user_id) do
    try do
      user = Accounts.get_user!(String.to_integer(user_id))
      {:ok, user}
    rescue
      Ecto.NoResultsError -> {:error, :user_not_found}
      ArgumentError -> {:error, :user_not_found}
    end
  end
end
