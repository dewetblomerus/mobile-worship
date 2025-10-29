defmodule MobileWorshipWeb.SetLive.Form do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Content
  alias MobileWorship.Sets
  alias MobileWorship.Sets.Set

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.header>
        {@page_title}
        <:subtitle>Add songs to your set and arrange them in order.</:subtitle>
      </.header>

      <.form for={@form} id="set-form" phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} type="text" label="Set Name" />

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">Available Songs</h2>
              <div class="space-y-2 max-h-[600px] overflow-y-auto">
                <div :for={song <- @available_songs} class="form-control">
                  <label class="label cursor-pointer justify-start gap-3">
                    <input
                      type="checkbox"
                      class="checkbox checkbox-primary"
                      checked={song.id in @selected_song_ids}
                      phx-click="toggle-song"
                      phx-value-song-id={song.id}
                    />
                    <span class="label-text">{song.name}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">Songs in Set</h2>
              <div
                id="set-songs-list"
                phx-hook="Sortable"
                class="space-y-2 max-h-[600px] overflow-y-auto"
                data-group="set-songs"
              >
                <div
                  :for={{song, idx} <- Enum.with_index(@set_songs)}
                  id={"set-song-#{song.id}-#{idx}"}
                  class="alert cursor-move"
                  data-song-id={song.id}
                  data-position={idx}
                >
                  <div class="flex items-center gap-3 flex-1">
                    <.icon name="hero-bars-3" class="size-5 text-base-content/50" />
                    <span>{song.name}</span>
                  </div>
                  <button
                    type="button"
                    class="btn btn-ghost btn-sm btn-circle"
                    phx-click="remove-song"
                    phx-value-position={idx}
                  >
                    <.icon name="hero-x-mark" class="size-5" />
                  </button>
                </div>
              </div>
              <%= if @set_songs == [] do %>
                <div class="text-center text-base-content/50 py-8">
                  No songs in set. Check songs on the left to add them.
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <footer class="mt-6 flex gap-2">
          <.button type="submit" phx-disable-with="Saving..." variant="primary">
            Save Set
          </.button>
          <.button type="button" navigate={return_path(@return_to, @set)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)

      {:ok,
       socket
       |> assign(:return_to, return_to(params["return_to"]))
       |> assign(:organization, organization)
       |> apply_action(socket.assigns.live_action, params)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    set = Sets.get_set!(id, socket.assigns.organization.id)
    available_songs = Content.list_songs(socket.assigns.organization.id)

    socket
    |> assign(:page_title, "Edit Set")
    |> assign(:set, set)
    |> assign(:form, to_form(Sets.change_set(set)))
    |> assign(:available_songs, available_songs)
    |> assign(:selected_song_ids, set.song_ids || [])
    |> assign(:set_songs, get_songs_by_ids(available_songs, set.song_ids || []))
  end

  defp apply_action(socket, :new, _params) do
    set = %Set{}
    available_songs = Content.list_songs(socket.assigns.organization.id)

    socket
    |> assign(:page_title, "New Set")
    |> assign(:set, set)
    |> assign(:form, to_form(Sets.change_set(set)))
    |> assign(:available_songs, available_songs)
    |> assign(:selected_song_ids, [])
    |> assign(:set_songs, [])
  end

  @impl true
  def handle_event("validate", %{"set" => set_params}, socket) do
    changeset = Sets.change_set(socket.assigns.set, set_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("toggle-song", %{"song-id" => song_id_str}, socket) do
    song_id = String.to_integer(song_id_str)
    current_ids = socket.assigns.selected_song_ids

    new_ids =
      if song_id in current_ids do
        Enum.reject(current_ids, &(&1 == song_id))
      else
        current_ids ++ [song_id]
      end

    set_songs = get_songs_by_ids(socket.assigns.available_songs, new_ids)

    {:noreply,
     socket
     |> assign(:selected_song_ids, new_ids)
     |> assign(:set_songs, set_songs)}
  end

  def handle_event("remove-song", %{"position" => position_str}, socket) do
    position = String.to_integer(position_str)
    new_ids = List.delete_at(socket.assigns.selected_song_ids, position)
    set_songs = get_songs_by_ids(socket.assigns.available_songs, new_ids)

    {:noreply,
     socket
     |> assign(:selected_song_ids, new_ids)
     |> assign(:set_songs, set_songs)}
  end

  def handle_event("reorder", %{"old_index" => old_idx, "new_index" => new_idx}, socket) do
    old_index = if is_binary(old_idx), do: String.to_integer(old_idx), else: old_idx
    new_index = if is_binary(new_idx), do: String.to_integer(new_idx), else: new_idx

    song_ids = socket.assigns.selected_song_ids
    {song_id, remaining} = List.pop_at(song_ids, old_index)
    new_ids = List.insert_at(remaining, new_index, song_id)

    set_songs = get_songs_by_ids(socket.assigns.available_songs, new_ids)

    {:noreply,
     socket
     |> assign(:selected_song_ids, new_ids)
     |> assign(:set_songs, set_songs)}
  end

  def handle_event("save", %{"set" => set_params}, socket) do
    set_params = Map.put(set_params, "song_ids", socket.assigns.selected_song_ids)
    save_set(socket, socket.assigns.live_action, set_params)
  end

  defp save_set(socket, :edit, set_params) do
    case Sets.update_set(socket.assigns.set, set_params) do
      {:ok, set} ->
        {:noreply,
         socket
         |> put_flash(:info, "Set updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, set))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_set(socket, :new, set_params) do
    case Sets.create_set(
           socket.assigns.current_user,
           socket.assigns.organization.id,
           set_params
         ) do
      {:ok, set} ->
        {:noreply,
         socket
         |> put_flash(:info, "Set created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, set))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_songs_by_ids(available_songs, song_ids) do
    song_map = Map.new(available_songs, fn song -> {song.id, song} end)
    Enum.map(song_ids, fn id -> Map.get(song_map, id) end) |> Enum.reject(&is_nil/1)
  end

  defp return_path("index", _set), do: ~p"/sets"
  defp return_path("show", set), do: ~p"/sets/#{set}"
end
