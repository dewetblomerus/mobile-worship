defmodule MobileWorshipWeb.AuthController do
  use MobileWorshipWeb, :controller
  plug Ueberauth

  def request(conn, _params) do
    # This is handled by Ueberauth
    conn
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # Here you would typically:
    # 1. Find or create a user based on auth.uid
    # 2. Store user info in session
    # 3. Redirect to the appropriate page

    conn
    |> put_flash(:info, "Successfully authenticated as #{auth.info.email}!")
    |> put_session(:user_id, auth.uid)
    |> put_session(:user_email, auth.info.email)
    |> redirect(to: ~p"/")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: ~p"/")
  end
end
