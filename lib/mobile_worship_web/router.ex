defmodule MobileWorshipWeb.Router do
  use MobileWorshipWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MobileWorshipWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; " <>
          "script-src 'self' 'unsafe-inline' 'unsafe-eval'; " <>
          "style-src 'self' 'unsafe-inline'; " <>
          "img-src 'self' data: https:; " <>
          "font-src 'self' data:; " <>
          "connect-src 'self' ws: wss:;"
    }

    plug MobileWorshipWeb.Plugs.LoadCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MobileWorshipWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/songs", SongLive.Index, :index
    live "/songs/new", SongLive.Form, :new
    live "/songs/:id", SongLive.Show, :show
    live "/songs/:id/edit", SongLive.Form, :edit

    live "/sets", SetLive.Index, :index
    live "/sets/new", SetLive.Form, :new
    live "/sets/:id", SetLive.Show, :show
    live "/sets/:id/edit", SetLive.Form, :edit
    live "/sets/:set_id/present", SetLive.Present, :present
  end

  scope "/auth", MobileWorshipWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  if Application.compile_env(:mobile_worship, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MobileWorshipWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
