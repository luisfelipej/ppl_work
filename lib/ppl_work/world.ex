defmodule PplWork.World do
  @moduledoc """
  The World context manages avatars, movement, and interactions within spaces.
  """

  import Ecto.Query, warn: false
  alias PplWork.Repo
  alias PplWork.World.Avatar
  alias PplWork.Spaces
  alias PplWork.Accounts.User

  @doc """
  Gets all active avatars in a space.

  ## Examples

      iex> list_avatars_in_space(1)
      [%Avatar{}, ...]

  """
  def list_avatars_in_space(space_id) do
    Avatar
    |> where([a], a.space_id == ^space_id and a.is_active == true)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a user's avatar in a specific space.

  ## Examples

      iex> get_user_avatar(1, 1)
      %Avatar{}

      iex> get_user_avatar(1, 999)
      nil

  """
  def get_user_avatar(user_id, space_id) do
    Avatar
    |> where([a], a.user_id == ^user_id and a.space_id == ^space_id)
    |> Repo.one()
  end

  @doc """
  Gets an avatar by id with user preloaded.

  ## Examples

      iex> get_avatar!(123)
      %Avatar{user: %User{}}

  """
  def get_avatar!(id) do
    Avatar
    |> preload(:user)
    |> Repo.get!(id)
  end

  @doc """
  Joins a user to a space, creating or activating their avatar.

  ## Examples

      iex> join_space(%User{id: 1}, %Space{id: 1}, %{x: 25.0, y: 25.0})
      {:ok, %Avatar{}}

      iex> join_space(%User{id: 1}, %Space{id: 1}, %{x: -1.0, y: 0.0})
      {:error, %Ecto.Changeset{}}

  """
  def join_space(%User{} = user, space, position \\ %{}) do
    # Check if space is at capacity
    if Spaces.space_at_capacity?(space) do
      {:error, :space_at_capacity}
    else
      case get_user_avatar(user.id, space.id) do
        nil ->
          # Create new avatar
          create_avatar(user, space, position)

        avatar ->
          # Reactivate existing avatar
          activate_avatar(avatar, position)
      end
    end
  end

  @doc """
  Creates an avatar for a user in a space.
  """
  def create_avatar(%User{} = user, space, position \\ %{}) do
    default_position = %{
      x: (space.width / 2) |> Float.round(2),
      y: (space.height / 2) |> Float.round(2),
      direction: "down"
    }

    attrs =
      default_position
      |> Map.merge(position)
      |> Map.merge(%{user_id: user.id, space_id: space.id})

    result =
      %Avatar{}
      |> Avatar.create_changeset(attrs)
      |> Repo.insert()

    # Preload :user before returning
    case result do
      {:ok, avatar} -> {:ok, Repo.preload(avatar, :user)}
      error -> error
    end
  end

  @doc """
  Activates an existing avatar and optionally updates position.
  """
  def activate_avatar(%Avatar{} = avatar, position \\ %{}) do
    attrs =
      position
      |> Map.merge(%{is_active: true})

    result =
      avatar
      |> Avatar.movement_changeset(attrs)
      |> Repo.update()

    # Preload :user before returning
    case result do
      {:ok, updated_avatar} -> {:ok, Repo.preload(updated_avatar, :user)}
      error -> error
    end
  end

  @doc """
  Removes a user from a space by deactivating their avatar.

  ## Examples

      iex> leave_space(%User{id: 1}, 1)
      {:ok, %Avatar{}}

  """
  def leave_space(%User{} = user, space_id) do
    case get_user_avatar(user.id, space_id) do
      nil ->
        {:error, :not_in_space}

      avatar ->
        deactivate_avatar(avatar)
    end
  end

  @doc """
  Deactivates an avatar when a user leaves a space.
  """
  def deactivate_avatar(%Avatar{} = avatar) do
    avatar
    |> Avatar.status_changeset(%{is_active: false})
    |> Repo.update()
  end

  @doc """
  Moves an avatar to a new position.

  ## Examples

      iex> move_avatar(avatar, %{x: 10.0, y: 15.0, direction: "up"})
      {:ok, %Avatar{}}

  """
  def move_avatar(%Avatar{} = avatar, position) do
    space = Spaces.get_space!(avatar.space_id)

    # Validate position is within space bounds
    validated_position = validate_position_bounds(position, space)

    avatar
    |> Avatar.movement_changeset(validated_position)
    |> Repo.update()
  end

  @doc """
  Validates that a position is within space boundaries.
  """
  def validate_position_bounds(position, space) do
    x = Map.get(position, :x, 0.0) |> clamp(0.0, space.width * 1.0)
    y = Map.get(position, :y, 0.0) |> clamp(0.0, space.height * 1.0)

    position
    |> Map.put(:x, x)
    |> Map.put(:y, y)
  end

  @doc """
  Finds avatars within a certain distance (proximity) of a given position.

  ## Examples

      iex> find_nearby_avatars(1, 25.0, 25.0, 5.0)
      [%Avatar{}, ...]

  """
  def find_nearby_avatars(space_id, x, y, radius \\ 5.0) do
    Avatar
    |> where([a], a.space_id == ^space_id and a.is_active == true)
    |> preload(:user)
    |> Repo.all()
    |> Enum.filter(fn avatar ->
      distance = calculate_distance(x, y, avatar.x, avatar.y)
      distance <= radius
    end)
  end

  @doc """
  Calculates the Euclidean distance between two points.

  ## Examples

      iex> calculate_distance(0.0, 0.0, 3.0, 4.0)
      5.0

  """
  def calculate_distance(x1, y1, x2, y2) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  @doc """
  Groups avatars by proximity zones.
  Returns a map where keys are avatar IDs and values are lists of nearby avatar IDs.

  ## Examples

      iex> get_proximity_groups(1, 5.0)
      %{1 => [2, 3], 2 => [1, 3], 3 => [1, 2]}

  """
  def get_proximity_groups(space_id, radius \\ 5.0) do
    avatars = list_avatars_in_space(space_id)

    avatars
    |> Enum.map(fn avatar ->
      nearby =
        avatars
        |> Enum.filter(fn other ->
          other.id != avatar.id &&
            calculate_distance(avatar.x, avatar.y, other.x, other.y) <= radius
        end)
        |> Enum.map(& &1.id)

      {avatar.id, nearby}
    end)
    |> Map.new()
  end

  # Helper function to clamp a value between min and max
  defp clamp(value, min, max) do
    value
    |> max(min)
    |> min(max)
  end
end
