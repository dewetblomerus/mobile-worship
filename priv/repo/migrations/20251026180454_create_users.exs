defmodule MobileWorship.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :auth0_id, :string, null: false
      add :email, :string, null: false
      add :email_verified, :boolean, default: false, null: false
      add :name, :string, null: false
      add :picture, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:auth0_id])
  end
end
