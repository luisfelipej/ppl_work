defmodule PplWorkWeb.PageController do
  use PplWorkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
