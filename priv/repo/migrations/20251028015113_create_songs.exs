defmodule MobileWorship.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :name, :string, null: false
      add :parts, {:array, :string}, default: []
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, on_delete: :nilify_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:songs, [:organization_id])
    create index(:songs, [:created_by_id])
  end
end
