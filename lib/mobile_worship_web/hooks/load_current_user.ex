defmodule MobileWorshipWeb.Hooks.LoadCurrentUser do
  @moduledoc """
  Hook to load the current user in LiveViews.
  """

  import Phoenix.Component

  alias MobileWorship.Accounts

  def on_mount(:default, _params, session, socket) do
    case session["user_id"] do
      nil ->
        {:cont, assign(socket, :current_user, nil)}

      user_id ->
        case Accounts.get_user(user_id) do
          nil -> {:cont, assign(socket, :current_user, nil)}
          user -> {:cont, assign(socket, :current_user, user)}
        end
    end
  end
end
