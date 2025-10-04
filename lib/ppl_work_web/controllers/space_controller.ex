defmodule PplWorkWeb.SpaceController do
  use PplWorkWeb, :controller

  alias PplWork.Spaces
  alias PplWork.Spaces.Space

  action_fallback PplWorkWeb.FallbackController

  @doc """
  GET /api/spaces
  List all public spaces
  """
  def index(conn, _params) do
    spaces = Spaces.list_public_spaces()
    render(conn, :index, spaces: spaces)
  end

  @doc """
  POST /api/spaces
  Create a new space
  """
  def create(conn, %{"space" => space_params}) do
    with {:ok, %Space{} = space} <- Spaces.create_space(space_params) do
      conn
      |> put_status(:created)
      |> render(:show, space: space)
    end
  end

  @doc """
  GET /api/spaces/:id
  Get a specific space
  """
  def show(conn, %{"id" => id}) do
    space = Spaces.get_space!(id)
    render(conn, :show, space: space)
  end

  @doc """
  PUT /api/spaces/:id
  Update a space
  """
  def update(conn, %{"id" => id, "space" => space_params}) do
    space = Spaces.get_space!(id)

    with {:ok, %Space{} = space} <- Spaces.update_space(space, space_params) do
      render(conn, :show, space: space)
    end
  end

  @doc """
  DELETE /api/spaces/:id
  Delete a space
  """
  def delete(conn, %{"id" => id}) do
    space = Spaces.get_space!(id)

    with {:ok, %Space{}} <- Spaces.delete_space(space) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  GET /api/spaces/:id/occupancy
  Get current occupancy of a space
  """
  def occupancy(conn, %{"id" => id}) do
    space = Spaces.get_space!(id)
    occupancy = Spaces.get_space_occupancy(id)

    conn
    |> json(%{
      space_id: id,
      current_occupancy: occupancy,
      max_occupancy: space.max_occupancy,
      at_capacity: Spaces.space_at_capacity?(space)
    })
  end
end
