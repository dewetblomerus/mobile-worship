defmodule MobileWorship.Repo.Migrations.CreateOrganizationMemberships do
  use Ecto.Migration

  def change do
    create table(:organization_memberships) do
      add :role, :string, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:organization_memberships, [:organization_id])
    create index(:organization_memberships, [:user_id])
    create unique_index(:organization_memberships, [:user_id, :organization_id])

    create constraint(:organization_memberships, :role_must_be_valid,
             check: "role IN ('owner', 'editor', 'viewer')"
           )
  end
end
