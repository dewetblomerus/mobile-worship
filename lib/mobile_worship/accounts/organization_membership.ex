defmodule MobileWorship.Accounts.OrganizationMembership do
  @moduledoc """
  Schema for organization memberships.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "organization_memberships" do
    field :role, :string
    belongs_to :organization, MobileWorship.Organizations.Organization
    belongs_to :user, MobileWorship.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization_membership, attrs) do
    organization_membership
    |> cast(attrs, [:role, :organization_id, :user_id])
    |> validate_required([:role, :organization_id, :user_id])
    |> validate_inclusion(:role, ["owner", "editor", "viewer"])
    |> unique_constraint([:user_id, :organization_id])
  end
end
