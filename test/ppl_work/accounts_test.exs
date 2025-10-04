defmodule PplWork.AccountsTest do
  use PplWork.DataCase

  alias PplWork.Accounts

  describe "users" do
    alias PplWork.Accounts.User

    @valid_attrs %{
      email: "test@example.com",
      username: "testuser",
      password: "Password123"
    }
    @invalid_attrs %{email: nil, username: nil, password: nil}

    test "register_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.email == "test@example.com"
      assert user.username == "testuser"
      assert user.password_hash != nil
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    end

    test "register_user/1 hashes the password" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.password_hash != @valid_attrs.password
      assert Bcrypt.verify_pass(@valid_attrs.password, user.password_hash)
    end

    test "register_user/1 with duplicate email returns error" do
      assert {:ok, _user} = Accounts.register_user(@valid_attrs)

      assert {:error, changeset} =
               Accounts.register_user(%{@valid_attrs | username: "different"})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "authenticate_user/2 with valid credentials returns user" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      assert {:ok, authenticated_user} =
               Accounts.authenticate_user(@valid_attrs.email, @valid_attrs.password)

      assert authenticated_user.id == user.id
    end

    test "authenticate_user/2 with invalid password returns error" do
      {:ok, _user} = Accounts.register_user(@valid_attrs)

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user(@valid_attrs.email, "wrongpassword")
    end

    test "authenticate_user/2 with non-existent email returns error" do
      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("nonexistent@example.com", "password")
    end

    test "get_user!/1 returns the user with given id" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user_by_email/1 returns the user with given email" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert Accounts.get_user_by_email(user.email).id == user.id
    end

    test "get_user_by_username/1 returns the user with given username" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert Accounts.get_user_by_username(user.username).id == user.id
    end
  end
end
