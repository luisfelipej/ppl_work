defmodule PplWorkWeb.SpaceChannel do
  @moduledoc """
  Channel for real-time communication within a space.

  Handles:
  - User presence tracking
  - Avatar movement
  - Proximity-based events
  """
  use PplWorkWeb, :channel

  alias PplWork.{World, Spaces, Accounts}
  alias PplWorkWeb.Presence

  @proximity_radius 5.0

  @impl true
  def join("space:" <> space_id, %{"user_id" => user_id} = params, socket) do
    space_id = String.to_integer(space_id)
    user_id = user_id

    with {:ok, space} <- get_space(space_id),
         {:ok, user} <- get_user(user_id),
         {:ok, avatar} <- join_user_to_space(user, space, params) do
      # Assign data to socket
      socket =
        socket
        |> assign(:space_id, space_id)
        |> assign(:user_id, user_id)
        |> assign(:avatar_id, avatar.id)
        |> assign(:space, space)

      # Track presence
      send(self(), :after_join)

      # Send current state to the joining user
      {:ok, get_space_state(space_id, avatar), socket}
    else
      {:error, :space_at_capacity} ->
        {:error, %{reason: "Space is at maximum capacity"}}

      {:error, reason} ->
        {:error, %{reason: inspect(reason)}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    # Track the user's presence
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        avatar_id: socket.assigns.avatar_id,
        online_at: inspect(System.system_time(:second))
      })

    # Get avatar with user info
    avatar = World.get_avatar!(socket.assigns.avatar_id)

    # Broadcast to others that a user joined
    broadcast!(socket, "user_joined", %{
      user_id: socket.assigns.user_id,
      avatar: serialize_avatar(avatar)
    })

    # Send proximity update
    send(self(), :proximity_check)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:proximity_check, socket) do
    # Calculate and broadcast proximity updates
    proximity_groups = World.get_proximity_groups(socket.assigns.space_id, @proximity_radius)

    broadcast!(socket, "proximity_update", %{
      proximity_groups: proximity_groups
    })

    {:noreply, socket}
  end

  @impl true
  def handle_in("move", %{"x" => x, "y" => y} = params, socket) do
    avatar = World.get_avatar!(socket.assigns.avatar_id)
    direction = Map.get(params, "direction", avatar.direction)

    case World.move_avatar(avatar, %{x: x, y: y, direction: direction}) do
      {:ok, updated_avatar} ->
        # Broadcast movement to all users in the space
        broadcast!(socket, "user_moved", %{
          user_id: socket.assigns.user_id,
          avatar: serialize_avatar(updated_avatar)
        })

        # Trigger proximity check
        send(self(), :proximity_check)

        {:reply, {:ok, serialize_avatar(updated_avatar)}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset.errors}}, socket}
    end
  end

  @impl true
  def handle_in("get_state", _params, socket) do
    state = get_space_state(socket.assigns.space_id, nil)
    {:reply, {:ok, state}, socket}
  end

  @impl true
  def handle_in("get_nearby_users", %{"radius" => radius}, socket) do
    avatar = World.get_avatar!(socket.assigns.avatar_id)

    nearby =
      World.find_nearby_avatars(socket.assigns.space_id, avatar.x, avatar.y, radius)
      |> Enum.reject(&(&1.id == avatar.id))
      |> Enum.map(&serialize_avatar/1)

    {:reply, {:ok, %{nearby_users: nearby}}, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    # Deactivate avatar when user disconnects
    avatar = World.get_avatar!(socket.assigns.avatar_id)
    World.deactivate_avatar(avatar)

    # Broadcast that user left
    broadcast!(socket, "user_left", %{
      user_id: socket.assigns.user_id
    })

    :ok
  end

  # Private helper functions

  defp get_space(space_id) do
    try do
      space = Spaces.get_space!(space_id)
      {:ok, space}
    rescue
      Ecto.NoResultsError -> {:error, :space_not_found}
    end
  end

  defp get_user(user_id) do
    try do
      user = Accounts.get_user!(user_id)
      {:ok, user}
    rescue
      Ecto.NoResultsError -> {:error, :user_not_found}
    end
  end

  defp join_user_to_space(user, space, params) do
    position = %{
      x: Map.get(params, "x"),
      y: Map.get(params, "y"),
      direction: Map.get(params, "direction", "down")
    }

    # Remove nil values
    position = Enum.reject(position, fn {_k, v} -> is_nil(v) end) |> Map.new()

    World.join_space(user, space, position)
  end

  defp get_space_state(space_id, current_avatar) do
    avatars =
      World.list_avatars_in_space(space_id)
      |> Enum.map(&serialize_avatar/1)

    proximity_groups = World.get_proximity_groups(space_id, @proximity_radius)

    state = %{
      avatars: avatars,
      proximity_groups: proximity_groups
    }

    if current_avatar do
      Map.put(state, :current_avatar, serialize_avatar(current_avatar))
    else
      state
    end
  end

  defp serialize_avatar(avatar) do
    %{
      id: avatar.id,
      user_id: avatar.user_id,
      username: avatar.user.username,
      x: avatar.x,
      y: avatar.y,
      direction: avatar.direction,
      is_active: avatar.is_active
    }
  end
end
