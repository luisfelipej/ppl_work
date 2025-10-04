defmodule PplWork.SpacesTest do
  use PplWork.DataCase

  alias PplWork.Spaces

  describe "spaces" do
    alias PplWork.Spaces.Space

    @valid_attrs %{
      name: "Test Space",
      width: 100,
      height: 100,
      description: "A test space",
      is_public: true,
      max_occupancy: 50
    }
    @invalid_attrs %{name: nil, width: nil, height: nil}

    test "create_space/1 with valid data creates a space" do
      assert {:ok, %Space{} = space} = Spaces.create_space(@valid_attrs)
      assert space.name == "Test Space"
      assert space.width == 100
      assert space.height == 100
    end

    test "create_space/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spaces.create_space(@invalid_attrs)
    end

    test "get_space!/1 returns the space with given id" do
      {:ok, space} = Spaces.create_space(@valid_attrs)
      assert Spaces.get_space!(space.id).id == space.id
    end

    test "list_public_spaces/0 returns all public spaces" do
      {:ok, space1} = Spaces.create_space(@valid_attrs)
      {:ok, _space2} = Spaces.create_space(%{@valid_attrs | is_public: false})

      public_spaces = Spaces.list_public_spaces()
      assert length(public_spaces) == 1
      assert hd(public_spaces).id == space1.id
    end

    test "update_space/2 with valid data updates the space" do
      {:ok, space} = Spaces.create_space(@valid_attrs)
      update_attrs = %{name: "Updated Space Name"}

      assert {:ok, %Space{} = updated_space} = Spaces.update_space(space, update_attrs)
      assert updated_space.name == "Updated Space Name"
    end

    test "delete_space/1 deletes the space" do
      {:ok, space} = Spaces.create_space(@valid_attrs)
      assert {:ok, %Space{}} = Spaces.delete_space(space)
      assert_raise Ecto.NoResultsError, fn -> Spaces.get_space!(space.id) end
    end
  end
end
