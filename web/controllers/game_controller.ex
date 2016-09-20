defmodule Reactor.GameController do
  use Reactor.Web, :controller
  alias Reactor.GameManager

  def index(conn, _params) do
    user = get_session(conn, :user)

    render(conn, "index.html", user: user)
  end

  def create(conn, %{"game" => %{"name" => name}}) do
    user = get_session(conn, :user)
    {:ok, %{id: id}} = GameManager.create_game(name, user)

    redirect(conn, to: game_path(conn, :show, id, user: user))
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
