defmodule MobileWorshipWeb.SetLive.PresentTest do
  use MobileWorshipWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MobileWorship.ContentFixtures
  import MobileWorship.SetsFixtures

  alias MobileWorship.Accounts
  alias MobileWorship.PresentationCache

  setup :log_in_user

  setup %{user: user} do
    organization = Accounts.get_personal_organization(user.id)

    song1 = song_fixture(%{user: user, name: "Song 1", parts: ["Verse 1", "Chorus 1"]})
    song2 = song_fixture(%{user: user, name: "Song 2", parts: ["Verse 2", "Chorus 2"]})

    set = set_fixture(%{user: user, name: "Test Set", song_ids: [song1.id, song2.id]})

    %{organization: organization, set: set}
  end

  describe "Present view" do
    test "caches current part in ETS on mount", %{conn: conn, set: set} do
      # Clear any existing cache
      PresentationCache.clear_current_part(set.id)

      {:ok, _view, _html} = live(conn, ~p"/sets/#{set}/present")

      # The first part should be cached
      cached_part = PresentationCache.get_current_part(set.id)
      assert cached_part != nil
      assert cached_part.content == "Verse 1"
    end

    test "updates ETS cache when navigating to next part", %{conn: conn, set: set} do
      {:ok, view, _html} = live(conn, ~p"/sets/#{set}/present")

      # Initial part should be cached
      initial_cached = PresentationCache.get_current_part(set.id)
      assert initial_cached.content == "Verse 1"

      # Navigate to next part
      view |> element("button[phx-click='next']") |> render_click()

      # Cache should be updated
      updated_cached = PresentationCache.get_current_part(set.id)
      assert updated_cached.content == "Chorus 1"
    end

    test "updates ETS cache when navigating to previous part", %{conn: conn, set: set} do
      {:ok, view, _html} = live(conn, ~p"/sets/#{set}/present")

      # Navigate to next part first
      view |> element("button[phx-click='next']") |> render_click()

      cached_part = PresentationCache.get_current_part(set.id)
      assert cached_part.content == "Chorus 1"

      # Navigate back to previous part
      view |> element("button[phx-click='prev']") |> render_click()

      # Cache should be updated back to first part
      updated_cached = PresentationCache.get_current_part(set.id)
      assert updated_cached.content == "Verse 1"
    end

    test "broadcasts presentation update when changing slides", %{conn: conn, set: set} do
      {:ok, view, _html} = live(conn, ~p"/sets/#{set}/present")

      # Subscribe after mounting to avoid initial broadcast
      Phoenix.PubSub.subscribe(MobileWorship.PubSub, "set:#{set.id}:presentation")

      # Navigate to next part
      view |> element("button[phx-click='next']") |> render_click()

      # Should receive broadcast for the next part
      assert_receive {:presentation_update, part}
      assert part.content == "Chorus 1"
    end
  end
end
