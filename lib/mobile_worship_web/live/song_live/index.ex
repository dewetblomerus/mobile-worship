defmodule MobileWorshipWeb.SongLive.Index do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Content
  alias MobileWorship.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Songs
        <:actions>
          <.button variant="primary" navigate={~p"/songs/new"}>
            <.icon name="hero-plus" /> New Song
          </.button>
        </:actions>
      </.header>

      <.table
        id="songs"
        rows={@streams.songs}
        row_click={fn {_id, song} -> JS.navigate(~p"/songs/#{song}") end}
      >
        <:col :let={{_id, song}} label="Name">{song.name}</:col>
        <:col :let={{_id, song}} label="Parts">{length(song.parts || [])} parts</:col>
        <:action :let={{_id, song}}>
          <div class="sr-only">
            <.link navigate={~p"/songs/#{song}"}>Show</.link>
          </div>
          <.link navigate={~p"/songs/#{song}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, song}}>
          <.link
            phx-click={JS.push("delete", value: %{id: song.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)

      {:ok,
       socket
       |> assign(:page_title, "Listing Songs")
       |> assign(:organization, organization)
       |> stream(:songs, list_songs(organization.id))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    song = Content.get_song!(id, socket.assigns.organization.id)
    {:ok, _} = Content.delete_song(song)

    {:noreply, stream_delete(socket, :songs, song)}
  end

  defp list_songs(organization_id) do
    Content.list_songs(organization_id)
  end
end
