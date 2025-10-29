defmodule MobileWorshipWeb.SetLive.Show do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Content
  alias MobileWorship.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.header>
        {@set.name}
        <:actions>
          <.button navigate={~p"/sets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/sets/#{@set}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit set
          </.button>
          <.button navigate={~p"/sets/#{@set.id}/present"}>
            <.icon name="hero-presentation-chart-bar" /> Present
          </.button>
          <.button navigate={~p"/sets/#{@set.id}/follow"}>
            <.icon name="hero-eye" /> Follow
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Songs">
          <ol class="list-decimal list-inside">
            <li :for={song <- @set_songs}>{song.name}</li>
          </ol>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)
      set = Sets.get_set!(id, organization.id)
      songs = Content.list_songs(organization.id)
      set_songs = get_songs_by_ids(songs, set.song_ids || [])

      {:ok,
       socket
       |> assign(:page_title, "Show Set")
       |> assign(:organization, organization)
       |> assign(:set, set)
       |> assign(:set_songs, set_songs)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end

  defp get_songs_by_ids(available_songs, song_ids) do
    song_map = Map.new(available_songs, fn song -> {song.id, song} end)
    Enum.map(song_ids, fn id -> Map.get(song_map, id) end) |> Enum.reject(&is_nil/1)
  end
end
