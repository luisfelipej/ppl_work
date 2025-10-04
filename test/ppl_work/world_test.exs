defmodule PplWork.WorldTest do
  use PplWork.DataCase

  alias PplWork.{World, Accounts, Spaces}

  describe "avatars" do
    setup do
      {:ok, user} =
        Accounts.register_user(%{
          email: "test@example.com",
          username: "testuser",
          password: "Password123"
        })

      {:ok, space} =
        Spaces.create_space(%{
          name: "Test Space",
          width: 100,
          height: 100
        })

      %{user: user, space: space}
    end

    test "join_space/3 creates an avatar for user in space", %{user: user, space: space} do
      assert {:ok, avatar} = World.join_space(user, space)
      assert avatar.user_id == user.id
      assert avatar.space_id == space.id
      assert avatar.is_active == true
    end

    test "join_space/3 with custom position", %{user: user, space: space} do
      position = %{x: 10.0, y: 20.0, direction: "up"}
      assert {:ok, avatar} = World.join_space(user, space, position)
      assert avatar.x == 10.0
      assert avatar.y == 20.0
      assert avatar.direction == "up"
    end

    test "leave_space/2 deactivates avatar", %{user: user, space: space} do
      {:ok, avatar} = World.join_space(user, space)
      assert avatar.is_active == true

      assert {:ok, updated_avatar} = World.leave_space(user, space.id)
      assert updated_avatar.is_active == false
    end

    test "move_avatar/2 updates avatar position", %{user: user, space: space} do
      {:ok, avatar} = World.join_space(user, space)

      new_position = %{x: 25.0, y: 30.0, direction: "right"}
      assert {:ok, moved_avatar} = World.move_avatar(avatar, new_position)
      assert moved_avatar.x == 25.0
      assert moved_avatar.y == 30.0
      assert moved_avatar.direction == "right"
    end

    test "move_avatar/2 validates position bounds", %{user: user, space: space} do
      {:ok, avatar} = World.join_space(user, space)

      # Try to move outside bounds
      out_of_bounds = %{x: -10.0, y: 200.0}
      assert {:ok, moved_avatar} = World.move_avatar(avatar, out_of_bounds)

      # Position should be clamped to space bounds
      assert moved_avatar.x >= 0.0
      assert moved_avatar.y <= space.height * 1.0
    end

    test "calculate_distance/4 calculates Euclidean distance" do
      assert World.calculate_distance(0.0, 0.0, 3.0, 4.0) == 5.0
      assert World.calculate_distance(0.0, 0.0, 0.0, 0.0) == 0.0
    end

    test "find_nearby_avatars/4 finds avatars within radius", %{space: space} do
      {:ok, user1} =
        Accounts.register_user(%{
          email: "user1@example.com",
          username: "user1",
          password: "Password123"
        })

      {:ok, user2} =
        Accounts.register_user(%{
          email: "user2@example.com",
          username: "user2",
          password: "Password123"
        })

      {:ok, _avatar1} = World.join_space(user1, space, %{x: 10.0, y: 10.0})
      {:ok, _avatar2} = World.join_space(user2, space, %{x: 12.0, y: 12.0})

      # Find avatars near position (10, 10) within radius 5
      nearby = World.find_nearby_avatars(space.id, 10.0, 10.0, 5.0)
      assert length(nearby) == 2
    end

    test "list_avatars_in_space/1 returns all active avatars", %{user: user, space: space} do
      {:ok, _avatar} = World.join_space(user, space)

      avatars = World.list_avatars_in_space(space.id)
      assert length(avatars) == 1
    end

    test "space_at_capacity?/1 returns true when space is full", %{space: space} do
      # Update space to have max occupancy of 1
      {:ok, space} = Spaces.update_space(space, %{max_occupancy: 1})

      {:ok, user1} =
        Accounts.register_user(%{
          email: "user1@example.com",
          username: "user1",
          password: "Password123"
        })

      {:ok, user2} =
        Accounts.register_user(%{
          email: "user2@example.com",
          username: "user2",
          password: "Password123"
        })

      # First user joins successfully
      assert {:ok, _avatar} = World.join_space(user1, space)

      # Space should be at capacity
      assert Spaces.space_at_capacity?(space) == true

      # Second user should be rejected
      assert {:error, :space_at_capacity} = World.join_space(user2, space)
    end
  end
end
