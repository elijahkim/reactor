defmodule Reactor.GameController do
  use Reactor.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, _params) do
    {id, pid} = Reactor.GameManager.create_game

    redirect(conn, to: game_path(conn, :show, :id))
  end

  def show(conn, %{"id" => id}) do
    render(conn, "index.html")
  end
end
