defmodule MobileWorship.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MobileWorship.Content` context.
  """

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    user = attrs[:user] || MobileWorship.AccountsFixtures.user_fixture()
    organization = MobileWorship.Accounts.get_personal_organization(user.id)

    {:ok, song} =
      attrs
      |> Map.drop([:user])
      |> Enum.into(%{
        name: "some name",
        parts: ["option1", "option2"]
      })
      |> then(&MobileWorship.Content.create_song(user, organization.id, &1))

    song
  end
end
