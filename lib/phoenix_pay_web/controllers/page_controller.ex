defmodule PhoenixPayWeb.PageController do
  use PhoenixPayWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
