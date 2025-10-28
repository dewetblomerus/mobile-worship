defmodule MobileWorship.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MobileWorship.Repo

  alias MobileWorship.Accounts.OrganizationMembership
  alias MobileWorship.Accounts.User

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_auth0_id(auth0_id) do
    Repo.get_by(User, auth0_id: auth0_id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def list_user_organizations(user_id) do
    user = Repo.get!(User, user_id) |> Repo.preload(:organizations)
    user.organizations
  end

  def get_personal_organization(user_id) do
    from(om in OrganizationMembership,
      join: o in assoc(om, :organization),
      where: om.user_id == ^user_id,
      select: o,
      order_by: [asc: om.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  def upsert_with_auth0(auth0_user) do
    Repo.transaction(fn ->
      email_verified =
        get_in(auth0_user.extra.raw_info.user, ["email_verified"]) ||
          get_in(auth0_user.extra.raw_info, ["email_verified"]) ||
          false

      user_attrs = %{
        auth0_id: auth0_user.uid,
        email: auth0_user.info.email,
        email_verified: email_verified,
        name: auth0_user.info.name,
        picture: auth0_user.info.image
      }

      user =
        case get_user_by_auth0_id(auth0_user.uid) do
          nil ->
            {:ok, user} =
              %User{}
              |> User.changeset(user_attrs)
              |> Repo.insert()

            {:ok, org} = MobileWorship.Organizations.create_organization(%{name: "Personal"})

            {:ok, _membership} =
              %OrganizationMembership{}
              |> OrganizationMembership.changeset(%{
                user_id: user.id,
                organization_id: org.id,
                role: "owner"
              })
              |> Repo.insert()

            user

          existing_user ->
            {:ok, user} =
              existing_user
              |> User.changeset(user_attrs)
              |> Repo.update()

            user
        end

      user
    end)
  end

  def create_membership(user_id, organization_id, role) do
    %OrganizationMembership{}
    |> OrganizationMembership.changeset(%{
      user_id: user_id,
      organization_id: organization_id,
      role: role
    })
    |> Repo.insert()
  end
end
