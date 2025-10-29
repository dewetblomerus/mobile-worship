defmodule MobileWorship.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :name, :string, null: false
      add :song_ids, {:array, :integer}, default: []
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sets, [:organization_id])
    create index(:sets, [:created_by_id])
  end
end
