defmodule MobileWorship.ContentTest do
  use MobileWorship.DataCase

  alias MobileWorship.Content

  describe "songs" do
    alias MobileWorship.Content.Song

    import MobileWorship.ContentFixtures
    import MobileWorship.AccountsFixtures

    @invalid_attrs %{name: nil, parts: nil}

    test "list_songs/1 returns all songs for an organization" do
      song = song_fixture()
      assert Content.list_songs(song.organization_id) == [song]
    end

    test "get_song!/2 returns the song with given id and organization" do
      song = song_fixture()
      assert Content.get_song!(song.id, song.organization_id) == song
    end

    test "create_song/3 with valid data creates a song" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      valid_attrs = %{name: "some name", parts: ["option1", "option2"]}

      assert {:ok, %Song{} = song} = Content.create_song(user, organization.id, valid_attrs)
      assert song.name == "some name"
      assert song.parts == ["option1", "option2"]
      assert song.organization_id == organization.id
      assert song.created_by_id == user.id
    end

    test "create_song/3 with invalid data returns error changeset" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)

      assert {:error, %Ecto.Changeset{}} =
               Content.create_song(user, organization.id, @invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      update_attrs = %{name: "some updated name", parts: ["option1"]}

      assert {:ok, %Song{} = song} = Content.update_song(song, update_attrs)
      assert song.name == "some updated name"
      assert song.parts == ["option1"]
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_song(song, @invalid_attrs)
      assert song == Content.get_song!(song.id, song.organization_id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Content.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Content.get_song!(song.id, song.organization_id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Content.change_song(song)
    end
  end
end
