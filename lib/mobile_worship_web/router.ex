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
