defmodule MmoWeb.PageController do
  use MmoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
