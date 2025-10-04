defmodule PplWork.Spaces.Space do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spaces" do
    field :name, :string
    field :width, :integer, default: 50
    field :height, :integer, default: 50
    field :description, :string
    field :is_public, :boolean, default: true
    field :max_occupancy, :integer, default: 50

    has_many :avatars, PplWork.World.Avatar

    timestamps()
  end

  @doc """
  Changeset for creating and updating spaces.
  """
  def changeset(space, attrs) do
    space
    |> cast(attrs, [:name, :width, :height, :description, :is_public, :max_occupancy])
    |> validate_required([:name, :width, :height])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_number(:width, greater_than: 0, less_than_or_equal_to: 1000)
    |> validate_number(:height, greater_than: 0, less_than_or_equal_to: 1000)
    |> validate_number(:max_occupancy, greater_than: 0, less_than_or_equal_to: 500)
  end
end
