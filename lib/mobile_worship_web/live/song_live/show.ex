defmodule MobileWorshipWeb.SongLive.Show do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Content

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.header>
        {@song.name}
        <:subtitle>Song details</:subtitle>
        <:actions>
          <.button navigate={~p"/songs"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/songs/#{@song}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit song
          </.button>
        </:actions>
      </.header>

      <div class="mt-6">
        <h3 class="text-lg font-semibold mb-4">Parts</h3>
        <div class="space-y-4">
          <div
            :for={{part, index} <- Enum.with_index(@song.parts || [], 1)}
            class="p-4 bg-base-200 rounded-lg"
          >
            <div class="text-sm text-base-content/60 mb-1">Part {index}</div>
            <div class="whitespace-pre-wrap">{part}</div>
          </div>
          <div :if={@song.parts == [] || @song.parts == nil} class="text-base-content/60 italic">
            No parts yet
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)
      song = Content.get_song!(id, organization.id)

      {:ok,
       socket
       |> assign(:page_title, "Show Song")
       |> assign(:organization, organization)
       |> assign(:song, song)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end
end
