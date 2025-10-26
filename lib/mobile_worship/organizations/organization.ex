defmodule MobileWorship.Organizations.Organization do
  @moduledoc """
  Schema for organizations.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string

    has_many :organization_memberships, MobileWorship.Accounts.OrganizationMembership
    has_many :users, through: [:organization_memberships, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
