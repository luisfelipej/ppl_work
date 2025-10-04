defmodule PplWork.Repo.Migrations.CreateSpaces do
  use Ecto.Migration

  def change do
    create table(:spaces) do
      add :name, :string, null: false
      add :width, :integer, null: false, default: 50
      add :height, :integer, null: false, default: 50
      add :description, :text
      add :is_public, :boolean, default: true
      add :max_occupancy, :integer, default: 50

      timestamps()
    end

    create index(:spaces, [:is_public])
  end
end
