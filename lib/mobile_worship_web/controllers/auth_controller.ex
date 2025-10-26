defmodule MobileWorshipWeb.AuthController do
  use MobileWorshipWeb, :controller
  plug Ueberauth

  alias MobileWorship.Accounts

  def request(conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.upsert_with_auth0(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated as #{user.email}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to create or update user.")
        |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: ~p"/")
  end
end
