defmodule MobileWorship.Accounts.User do
  @moduledoc """
  Schema for users.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :auth0_id, :string
    field :email, :string
    field :email_verified, :boolean, default: false
    field :name, :string
    field :picture, :string

    has_many :organization_memberships, MobileWorship.Accounts.OrganizationMembership
    has_many :organizations, through: [:organization_memberships, :organization]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:auth0_id, :email, :email_verified, :name, :picture])
    |> validate_required([:auth0_id, :email, :email_verified, :name])
    |> unique_constraint(:email)
    |> unique_constraint(:auth0_id)
  end
end
