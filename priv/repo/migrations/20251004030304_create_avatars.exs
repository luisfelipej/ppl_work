defmodule PplWork.Repo.Migrations.CreateAvatars do
  use Ecto.Migration

  def change do
    create table(:avatars) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :space_id, references(:spaces, on_delete: :delete_all), null: false
      add :x, :float, null: false, default: 0.0
      add :y, :float, null: false, default: 0.0
      add :direction, :string, default: "down"
      add :is_active, :boolean, default: true

      timestamps()
    end

    create index(:avatars, [:user_id])
    create index(:avatars, [:space_id])
    create index(:avatars, [:space_id, :is_active])
    create unique_index(:avatars, [:user_id, :space_id])
  end
end
