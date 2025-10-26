defmodule MobileWorship.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias MobileWorship.Repo

  alias MobileWorship.Organizations.Organization

  def get_organization(id), do: Repo.get(Organization, id)

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end
end
