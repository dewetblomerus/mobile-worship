defmodule MobileWorshipWeb.Plugs.LoadCurrentUser do
  @moduledoc """
  Plug to load the current user from the session.
  """

  import Plug.Conn
  alias MobileWorship.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      case Accounts.get_user(user_id) do
        nil -> assign(conn, :current_user, nil)
        user -> assign(conn, :current_user, user)
      end
    else
      assign(conn, :current_user, nil)
    end
  end
end
