defmodule PplWorkWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PplWorkWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: PplWorkWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: PplWorkWeb.ErrorHTML, json: PplWorkWeb.ErrorJSON)
    |> render(:"404")
  end

  # Handle space at capacity error
  def call(conn, {:error, :space_at_capacity}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Space is at maximum capacity"})
  end
end
