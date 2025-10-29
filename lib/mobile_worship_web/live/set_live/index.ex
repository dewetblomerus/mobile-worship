defmodule MobileWorshipWeb.SetLive.Index do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.header>
        Sets
        <:actions>
          <.button variant="primary" navigate={~p"/sets/new"}>
            <.icon name="hero-plus" /> New Set
          </.button>
        </:actions>
      </.header>

      <.table
        id="sets"
        rows={@streams.sets}
        row_click={fn {_id, set} -> JS.navigate(~p"/sets/#{set}") end}
      >
        <:col :let={{_id, set}} label="Name">{set.name}</:col>
        <:col :let={{_id, set}} label="Songs">{length(set.song_ids || [])} songs</:col>
        <:action :let={{_id, set}}>
          <div class="sr-only">
            <.link navigate={~p"/sets/#{set}"}>Show</.link>
          </div>
          <.link navigate={~p"/sets/#{set}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, set}}>
          <.link
            phx-click={JS.push("delete", value: %{id: set.id}) |> hide("##{id}")}
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
       |> assign(:page_title, "Listing Sets")
       |> assign(:organization, organization)
       |> stream(:sets, list_sets(organization.id))}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    set = Sets.get_set!(id, socket.assigns.organization.id)
    {:ok, _} = Sets.delete_set(set)

    {:noreply, stream_delete(socket, :sets, set)}
  end

  defp list_sets(organization_id) do
    Sets.list_sets(organization_id)
  end
end
