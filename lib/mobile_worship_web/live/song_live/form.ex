defmodule MobileWorshipWeb.SongLive.Form do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Content
  alias MobileWorship.Content.Song

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage song records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="song-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:parts]}
          type="textarea"
          label="Parts (one per line)"
          phx-debounce="300"
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Song</.button>
          <.button navigate={return_path(@return_to, @song)}>Cancel</.button>
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
    song = Content.get_song!(id, socket.assigns.organization.id)

    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, song)
    |> assign(:form, to_form(Content.change_song(song) |> normalize_parts_for_form()))
  end

  defp apply_action(socket, :new, _params) do
    song = %Song{}

    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, song)
    |> assign(:form, to_form(Content.change_song(song) |> normalize_parts_for_form()))
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    song_params = normalize_parts_from_form(song_params)
    changeset = Content.change_song(socket.assigns.song, song_params)

    {:noreply,
     assign(socket, form: to_form(changeset |> normalize_parts_for_form(), action: :validate))}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    song_params = normalize_parts_from_form(song_params)
    save_song(socket, socket.assigns.live_action, song_params)
  end

  defp save_song(socket, :edit, song_params) do
    case Content.update_song(socket.assigns.song, song_params) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Song updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_song(socket, :new, song_params) do
    case Content.create_song(
           socket.assigns.current_user,
           socket.assigns.organization.id,
           song_params
         ) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Song created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset |> normalize_parts_for_form()))}
    end
  end

  defp normalize_parts_from_form(%{"parts" => parts} = params) when is_binary(parts) do
    parts_array =
      parts
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(params, "parts", parts_array)
  end

  defp normalize_parts_from_form(params), do: params

  defp normalize_parts_for_form(%Ecto.Changeset{} = changeset) do
    case Ecto.Changeset.get_field(changeset, :parts) do
      nil ->
        changeset

      [] ->
        changeset

      parts when is_list(parts) ->
        Ecto.Changeset.put_change(changeset, :parts, Enum.join(parts, "\n"))

      _other ->
        changeset
    end
  end

  defp return_path("index", _song), do: ~p"/songs"
  defp return_path("show", song), do: ~p"/songs/#{song}"
end
