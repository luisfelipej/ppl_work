defmodule PplWorkWeb.SpaceJSON do
  alias PplWork.Spaces.Space

  @doc """
  Renders a list of spaces.
  """
  def index(%{spaces: spaces}) do
    %{data: for(space <- spaces, do: data(space))}
  end

  @doc """
  Renders a single space.
  """
  def show(%{space: space}) do
    %{data: data(space)}
  end

  defp data(%Space{} = space) do
    %{
      id: space.id,
      name: space.name,
      width: space.width,
      height: space.height,
      description: space.description,
      is_public: space.is_public,
      max_occupancy: space.max_occupancy,
      inserted_at: space.inserted_at,
      updated_at: space.updated_at
    }
  end
end
