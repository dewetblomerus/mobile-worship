defmodule MobileWorshipWeb.SetLive.Present do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.PresentationCache
  alias MobileWorship.Sets
  alias QRCode

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="min-h-screen bg-base-200 py-8" phx-window-keydown="keydown">
        <%= if @qr_svg_base64 do %>
          <div class="fixed right-4 top-20 z-10 flex flex-col items-center gap-2">
            <div class="card bg-base-100 shadow-xl border border-base-200 p-3">
              <img
                src={"data:image/svg+xml;base64,#{@qr_svg_base64}"}
                alt="Follow on your device"
                class="w-60 h-60"
                width="128"
                height="128"
              />
            </div>
            <a href={@follow_url} target="_blank" class="link link-primary text-sm">
              Open follow page
            </a>
          </div>
        <% end %>
        <div class="container mx-auto px-4">
          <div class="mb-8 flex items-center justify-between">
            <h1 class="text-3xl font-bold">{@set.name}</h1>
            <.link navigate={~p"/sets/#{@set}"} class="btn btn-ghost">
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </.link>
          </div>

          <div class="relative">
            <%!-- Song List Sidebar --%>
            <div class="absolute left-0 top-0 w-40 flex-shrink-0">
              <div class="card bg-base-100 shadow-xl">
                <div class="card-body p-4">
                  <h2 class="card-title text-lg mb-2">Songs</h2>
                  <ul class="menu menu-compact p-0">
                    <li :for={{song, idx} <- Enum.with_index(@songs)}>
                      <a
                        phx-click="jump_to_song"
                        phx-value-song-index={idx}
                        class={[
                          "text-sm",
                          @current_song_index == idx && "active bg-primary text-primary-content"
                        ]}
                      >
                        {if String.length(song.name) > 12,
                          do: String.slice(song.name, 0, 12) <> "...",
                          else: song.name}
                      </a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            <%!-- Slides Display --%>
            <div class="flex flex-col items-center">
              <div class="flex items-center justify-center gap-8">
                <div class="flex flex-col items-center">
                  <%= if @prev_part do %>
                    <div class="text-sm font-semibold mb-2 text-base-content/60">
                      {@prev_part.song_name}
                    </div>
                    <div class="w-48 h-96 bg-base-100 rounded-lg shadow-lg p-6 flex items-center justify-center opacity-60">
                      <div class="text-3xl leading-relaxed text-center">
                        {@prev_part.content}
                      </div>
                    </div>
                  <% else %>
                    <div class="w-48 h-96"></div>
                  <% end %>
                </div>

                <div class="flex flex-col items-center">
                  <%= if @current_part do %>
                    <div class="text-xl font-bold mb-4">
                      {@current_part.song_name}
                    </div>
                    <div class="w-72 h-[32rem] bg-base-100 rounded-lg shadow-2xl p-8 flex flex-col items-center justify-center border-4 border-primary">
                      <div class="flex flex-col items-center justify-center ">
                        <div class="text-5xl leading-relaxed text-center">
                          {@current_part.content}
                        </div>
                      </div>
                    </div>
                  <% else %>
                    <div class="w-64 h-[32rem] bg-base-100 rounded-lg shadow-2xl p-8 flex items-center justify-center">
                      <div class="text-center text-base-content/60">No parts in set</div>
                    </div>
                  <% end %>
                </div>

                <div class="flex flex-col items-center">
                  <%= if @next_part do %>
                    <div class="text-sm font-semibold mb-2 text-base-content/60">
                      {@next_part.song_name}
                    </div>
                    <div class="w-48 h-96 bg-base-100 rounded-lg shadow-lg p-6 flex items-center justify-center opacity-60">
                      <div class="text-3xl leading-relaxed text-center">
                        {@next_part.content}
                      </div>
                    </div>
                  <% else %>
                    <div class="w-48 h-96"></div>
                  <% end %>
                </div>
              </div>

              <div class="flex justify-center gap-4 mt-8">
                <button
                  class="btn btn-lg btn-circle"
                  phx-click="prev"
                  disabled={@current_index == 0}
                >
                  <.icon name="hero-arrow-left" class="w-8 h-8" />
                </button>
                <div class="flex items-center px-6 text-lg font-semibold">
                  {@current_index + 1} / {@total_parts}
                </div>
                <button
                  class="btn btn-lg btn-circle"
                  phx-click="next"
                  disabled={@current_index >= @total_parts - 1}
                >
                  <.icon name="hero-arrow-right" class="w-8 h-8" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"set_id" => set_id}, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)
      set = Sets.get_set!(set_id, organization.id)

      songs = Sets.get_set_songs(set, organization.id)
      total_parts = Enum.reduce(songs, 0, fn song, acc -> acc + length(song.parts) end)

      follow_url = url(~p"/sets/#{set}/follow")

      qr_svg_base64 =
        follow_url
        |> QRCode.create()
        |> QRCode.render(:svg)
        |> QRCode.to_base64()
        |> case do
          {:ok, b64} -> b64
          _ -> nil
        end

      {:ok,
       socket
       |> assign(:set, set)
       |> assign(:songs, songs)
       |> assign(:current_song_index, 0)
       |> assign(:current_part_index, 0)
       |> assign(:total_parts, total_parts)
       |> assign(:follow_url, follow_url)
       |> assign(:qr_svg_base64, qr_svg_base64)
       |> update_display()}
    else
      {:ok,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_event("next", _params, socket) do
    {:noreply, socket |> navigate_next() |> update_display()}
  end

  def handle_event("prev", _params, socket) do
    {:noreply, socket |> navigate_prev() |> update_display()}
  end

  def handle_event("keydown", %{"key" => key}, socket) when key in ["ArrowRight", " "] do
    handle_event("next", %{}, socket)
  end

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    handle_event("prev", %{}, socket)
  end

  def handle_event("jump_to_song", %{"song-index" => song_index_str}, socket) do
    song_index = String.to_integer(song_index_str)

    {:noreply,
     socket
     |> assign(:current_song_index, song_index)
     |> assign(:current_part_index, 0)
     |> update_display()}
  end

  def handle_event("keydown", _params, socket) do
    {:noreply, socket}
  end

  defp navigate_next(socket) do
    songs = socket.assigns.songs
    current_song_index = socket.assigns.current_song_index
    current_part_index = socket.assigns.current_part_index

    current_song = Enum.at(songs, current_song_index)

    if current_song && current_part_index < length(current_song.parts) - 1 do
      # Move to next part in current song
      assign(socket, :current_part_index, current_part_index + 1)
    else
      # Move to first part of next song
      if current_song_index < length(songs) - 1 do
        socket
        |> assign(:current_song_index, current_song_index + 1)
        |> assign(:current_part_index, 0)
      else
        # Already at the end
        socket
      end
    end
  end

  defp navigate_prev(socket) do
    songs = socket.assigns.songs
    current_song_index = socket.assigns.current_song_index
    current_part_index = socket.assigns.current_part_index

    if current_part_index > 0 do
      # Move to previous part in current song
      assign(socket, :current_part_index, current_part_index - 1)
    else
      # Move to last part of previous song
      if current_song_index > 0 do
        prev_song = Enum.at(songs, current_song_index - 1)

        socket
        |> assign(:current_song_index, current_song_index - 1)
        |> assign(:current_part_index, length(prev_song.parts) - 1)
      else
        # Already at the beginning
        socket
      end
    end
  end

  defp update_display(socket) do
    songs = socket.assigns.songs
    current_song_index = socket.assigns.current_song_index
    current_part_index = socket.assigns.current_part_index

    current_part = get_part_at(songs, current_song_index, current_part_index)
    prev_part = get_prev_part(songs, current_song_index, current_part_index)
    next_part = get_next_part(songs, current_song_index, current_part_index)

    # Calculate current index for display (1-based counting)
    current_index = calculate_global_index(songs, current_song_index, current_part_index)

    broadcast_presentation_update(socket.assigns.set.id, current_part)

    socket
    |> assign(:current_part, current_part)
    |> assign(:prev_part, prev_part)
    |> assign(:next_part, next_part)
    |> assign(:current_index, current_index)
  end

  defp get_part_at(songs, song_index, part_index) do
    case Enum.at(songs, song_index) do
      nil ->
        nil

      song ->
        case Enum.at(song.parts, part_index) do
          nil -> nil
          content -> %{song_name: song.name, content: content}
        end
    end
  end

  defp get_prev_part(songs, current_song_index, current_part_index) do
    if current_part_index > 0 do
      get_part_at(songs, current_song_index, current_part_index - 1)
    else
      if current_song_index > 0 do
        prev_song = Enum.at(songs, current_song_index - 1)
        get_part_at(songs, current_song_index - 1, length(prev_song.parts) - 1)
      else
        nil
      end
    end
  end

  defp get_next_part(songs, current_song_index, current_part_index) do
    current_song = Enum.at(songs, current_song_index)

    if current_song && current_part_index < length(current_song.parts) - 1 do
      get_part_at(songs, current_song_index, current_part_index + 1)
    else
      if current_song_index < length(songs) - 1 do
        get_part_at(songs, current_song_index + 1, 0)
      else
        nil
      end
    end
  end

  defp calculate_global_index(songs, current_song_index, current_part_index) do
    # Count all parts in songs before the current song
    parts_before =
      songs
      |> Enum.take(current_song_index)
      |> Enum.reduce(0, fn song, acc -> acc + length(song.parts) end)

    parts_before + current_part_index
  end

  defp broadcast_presentation_update(set_id, part) do
    # Cache the current part in ETS
    PresentationCache.put_current_part(set_id, part)

    Phoenix.PubSub.broadcast(
      MobileWorship.PubSub,
      "set:#{set_id}:presentation",
      {:presentation_update, part}
    )
  end
end
