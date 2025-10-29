defmodule MobileWorshipWeb.SetLive.Present do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.Accounts
  alias MobileWorship.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="min-h-screen bg-base-200 py-8" phx-window-keydown="keydown">
        <div class="container mx-auto px-4">
          <div class="mb-8 flex items-center justify-between">
            <h1 class="text-3xl font-bold">{@set.name}</h1>
            <.link navigate={~p"/sets/#{@set}"} class="btn btn-ghost">
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </.link>
          </div>

          <div class="flex items-center justify-center gap-8">
            <div class="flex flex-col items-center">
              <%= if @prev_part do %>
                <div class="text-sm font-semibold mb-2 text-base-content/60">
                  {@prev_part.song_name}
                </div>
                <div class="w-48 h-96 bg-base-100 rounded-lg shadow-lg p-6 flex items-center justify-center opacity-60">
                  <div class="text-center text-sm whitespace-pre-wrap overflow-y-auto max-h-full">
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
                <div class="w-64 h-[32rem] bg-base-100 rounded-lg shadow-2xl p-8 flex items-center justify-center border-4 border-primary">
                  <div class="text-center text-lg whitespace-pre-wrap overflow-y-auto max-h-full">
                    {@current_part.content}
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
                  <div class="text-center text-sm whitespace-pre-wrap overflow-y-auto max-h-full">
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
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"set_id" => set_id}, _session, socket) do
    if socket.assigns[:current_user] do
      organization = Accounts.get_personal_organization(socket.assigns.current_user.id)
      set = Sets.get_set!(set_id, organization.id)

      all_parts = Sets.get_set_parts(set, organization.id)

      {:ok,
       socket
       |> assign(:set, set)
       |> assign(:all_parts, all_parts)
       |> assign(:current_index, 0)
       |> assign(:total_parts, length(all_parts))
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
    new_index = min(socket.assigns.current_index + 1, socket.assigns.total_parts - 1)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> update_display()}
  end

  def handle_event("prev", _params, socket) do
    new_index = max(socket.assigns.current_index - 1, 0)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> update_display()}
  end

  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    handle_event("next", %{}, socket)
  end

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    handle_event("prev", %{}, socket)
  end

  def handle_event("keydown", _params, socket) do
    {:noreply, socket}
  end

  defp update_display(socket) do
    all_parts = socket.assigns.all_parts
    current_index = socket.assigns.current_index

    current_part = Enum.at(all_parts, current_index)
    prev_part = if current_index > 0, do: Enum.at(all_parts, current_index - 1), else: nil

    next_part =
      if current_index < length(all_parts) - 1,
        do: Enum.at(all_parts, current_index + 1),
        else: nil

    socket
    |> assign(:current_part, current_part)
    |> assign(:prev_part, prev_part)
    |> assign(:next_part, next_part)
  end
end
