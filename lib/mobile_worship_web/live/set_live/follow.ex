defmodule MobileWorshipWeb.SetLive.Follow do
  use MobileWorshipWeb, :live_view

  alias MobileWorship.PresentationCache
  alias MobileWorship.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-white flex items-center justify-center p-8">
      <div class="text-center max-w-4xl w-full">
        <div class="text-5xl whitespace-pre-wrap leading-relaxed">
          {@current_part.content}
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => set_id}, _session, socket) do
    # Try to get current part from cache first
    current_part = PresentationCache.get_current_part(set_id) || build_fallback_content(set_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(MobileWorship.PubSub, "set:#{set_id}:presentation")
    end

    {:ok,
     socket
     |> assign(:set_id, set_id)
     |> assign(:current_part, current_part)}
  end

  @impl true
  def handle_info({:presentation_update, part}, socket) do
    current_part = part || build_fallback_content(socket.assigns.set_id)
    {:noreply, assign(socket, :current_part, current_part)}
  end

  defp build_fallback_content(set_id) do
    %{content: Sets.get_set_by_id!(set_id).name}
  end
end
