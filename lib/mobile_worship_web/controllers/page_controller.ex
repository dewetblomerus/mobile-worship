defmodule MobileWorshipWeb.PageController do
  use MobileWorshipWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
