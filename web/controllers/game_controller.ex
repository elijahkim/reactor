defmodule Reactor.GameController do
  use Reactor.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"game" => %{"name" => name}} = params) do
    {id, _pid} = Reactor.GameManager.create_game

    redirect(conn, to: game_path(conn, :show, id, name: name))
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end
end
