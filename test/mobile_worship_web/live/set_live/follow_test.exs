defmodule MobileWorshipWeb.SetLive.FollowTest do
  use MobileWorshipWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MobileWorship.AccountsFixtures
  import MobileWorship.ContentFixtures
  import MobileWorship.SetsFixtures

  alias MobileWorship.Accounts
  alias MobileWorship.PresentationCache

  setup do
    user = user_fixture()
    organization = Accounts.get_personal_organization(user.id)

    song1 = song_fixture(%{user: user, parts: ["Verse 1", "Chorus 1"]})
    song2 = song_fixture(%{user: user, parts: ["Verse 2", "Chorus 2"]})

    set = set_fixture(%{user: user, name: "Test Set", song_ids: [song1.id, song2.id]})

    %{user: user, organization: organization, set: set}
  end

  describe "Follow view" do
    test "shows set name when no presentation is active", %{set: set} do
      {:ok, _view, html} = live(build_conn(), ~p"/sets/#{set.id}/follow")

      assert html =~ set.name
      refute html =~ "Verse 1"
    end

    test "shows cached part from ETS when presentation is already active", %{set: set} do
      # Simulate presenter caching a part in ETS
      cached_part = %{song_name: "Cached Song", content: "Cached Content"}
      PresentationCache.put_current_part(set.id, cached_part)

      # When a new viewer joins, they should immediately see the cached part
      {:ok, _view, html} = live(build_conn(), ~p"/sets/#{set.id}/follow")

      assert html =~ "Cached Content"
      refute html =~ set.name
    end

    test "shows set name when cache is empty", %{set: set} do
      # Ensure cache is empty
      PresentationCache.clear_current_part(set.id)

      {:ok, _view, html} = live(build_conn(), ~p"/sets/#{set.id}/follow")

      assert html =~ set.name
    end

    test "updates to show current part when presentation is active", %{set: set} do
      {:ok, view, _html} = live(build_conn(), ~p"/sets/#{set.id}/follow")

      current_part = %{song_name: "Test Song", content: "Test Content"}

      Phoenix.PubSub.broadcast(
        MobileWorship.PubSub,
        "set:#{set.id}:presentation",
        {:presentation_update, current_part}
      )

      assert render(view) =~ "Test Content"
    end

    test "shows set name when presentation part is nil", %{set: set} do
      {:ok, view, _html} = live(build_conn(), ~p"/sets/#{set.id}/follow")

      Phoenix.PubSub.broadcast(
        MobileWorship.PubSub,
        "set:#{set.id}:presentation",
        {:presentation_update, nil}
      )

      assert render(view) =~ set.name
    end
  end
end
