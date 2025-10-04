defmodule PplWork.Spaces do
  @moduledoc """
  The Spaces context manages virtual spaces where users can interact.
  """

  import Ecto.Query, warn: false
  alias PplWork.Repo
  alias PplWork.Spaces.Space

  @doc """
  Returns the list of public spaces.

  ## Examples

      iex> list_public_spaces()
      [%Space{}, ...]

  """
  def list_public_spaces do
    Space
    |> where([s], s.is_public == true)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of all spaces.

  ## Examples

      iex> list_spaces()
      [%Space{}, ...]

  """
  def list_spaces do
    Repo.all(Space)
  end

  @doc """
  Gets a single space.

  Raises `Ecto.NoResultsError` if the Space does not exist.

  ## Examples

      iex> get_space!(123)
      %Space{}

      iex> get_space!(456)
      ** (Ecto.NoResultsError)

  """
  def get_space!(id), do: Repo.get!(Space, id)

  @doc """
  Gets a space with all its active avatars preloaded.

  ## Examples

      iex> get_space_with_avatars!(123)
      %Space{avatars: [%Avatar{}, ...]}

  """
  def get_space_with_avatars!(id) do
    Space
    |> where([s], s.id == ^id)
    |> preload([s], avatars: [:user])
    |> Repo.one!()
  end

  @doc """
  Creates a space.

  ## Examples

      iex> create_space(%{name: "My Space", width: 100, height: 100})
      {:ok, %Space{}}

      iex> create_space(%{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_space(attrs \\ %{}) do
    %Space{}
    |> Space.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a space.

  ## Examples

      iex> update_space(space, %{name: "Updated Name"})
      {:ok, %Space{}}

      iex> update_space(space, %{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def update_space(%Space{} = space, attrs) do
    space
    |> Space.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a space.

  ## Examples

      iex> delete_space(space)
      {:ok, %Space{}}

      iex> delete_space(space)
      {:error, %Ecto.Changeset{}}

  """
  def delete_space(%Space{} = space) do
    Repo.delete(space)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking space changes.

  ## Examples

      iex> change_space(space)
      %Ecto.Changeset{data: %Space{}}

  """
  def change_space(%Space{} = space, attrs \\ %{}) do
    Space.changeset(space, attrs)
  end

  @doc """
  Gets the current occupancy of a space.

  ## Examples

      iex> get_space_occupancy(123)
      15

  """
  def get_space_occupancy(space_id) do
    alias PplWork.World.Avatar

    Avatar
    |> where([a], a.space_id == ^space_id and a.is_active == true)
    |> Repo.aggregate(:count)
  end

  @doc """
  Checks if a space is at max capacity.

  ## Examples

      iex> space_at_capacity?(space)
      false

  """
  def space_at_capacity?(%Space{} = space) do
    current_occupancy = get_space_occupancy(space.id)
    current_occupancy >= space.max_occupancy
  end
end
