defmodule MobileWorship.SetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MobileWorship.Sets` context.
  """

  alias MobileWorship.Accounts
  alias MobileWorship.AccountsFixtures

  @doc """
  Generate a set.
  """
  def set_fixture(attrs \\ %{}) do
    user = attrs[:user] || AccountsFixtures.user_fixture()
    organization = Accounts.get_personal_organization(user.id)

    {:ok, set} =
      attrs
      |> Enum.into(%{
        name: "some name",
        song_ids: []
      })
      |> Map.drop([:user])
      |> then(&MobileWorship.Sets.create_set(user, organization.id, &1))

    set
  end
end
