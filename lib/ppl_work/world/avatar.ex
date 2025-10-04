defmodule PplWork.World.Avatar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "avatars" do
    field :x, :float, default: 0.0
    field :y, :float, default: 0.0
    field :direction, :string, default: "down"
    field :is_active, :boolean, default: true

    belongs_to :user, PplWork.Accounts.User
    belongs_to :space, PplWork.Spaces.Space

    timestamps()
  end

  @doc """
  Changeset for creating an avatar when a user joins a space.
  """
  def create_changeset(avatar, attrs) do
    avatar
    |> cast(attrs, [:user_id, :space_id, :x, :y, :direction])
    |> validate_required([:user_id, :space_id])
    |> validate_coordinates()
    |> validate_direction()
    |> unique_constraint([:user_id, :space_id])
  end

  @doc """
  Changeset for updating avatar position and direction.
  """
  def movement_changeset(avatar, attrs) do
    avatar
    |> cast(attrs, [:x, :y, :direction])
    |> validate_coordinates()
    |> validate_direction()
    |> validate_movement_bounds()
  end

  @doc """
  Changeset for updating avatar active status.
  """
  def status_changeset(avatar, attrs) do
    avatar
    |> cast(attrs, [:is_active])
    |> validate_required([:is_active])
  end

  defp validate_coordinates(changeset) do
    changeset
    |> validate_number(:x, greater_than_or_equal_to: 0.0)
    |> validate_number(:y, greater_than_or_equal_to: 0.0)
  end

  defp validate_direction(changeset) do
    validate_inclusion(changeset, :direction, ["up", "down", "left", "right"],
      message: "must be one of: up, down, left, right"
    )
  end

  defp validate_movement_bounds(changeset) do
    # This will be enhanced to validate against space boundaries
    # For now, just basic validation
    changeset
  end
end
