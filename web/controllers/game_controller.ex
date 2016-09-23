defmodule Reactor.GameController do
  use Reactor.Web, :controller
  alias Reactor.GameManager

  def index(conn, _params) do
    user = get_session(conn, :user)

    render(conn, "index.html", user: user)
  end

  def new(conn, _params) do
    user = get_session(conn, :user)

    render(conn, "new.html", user: user)
  end

  def create(conn, %{"game" => %{"name" => name, "up_to" => up_to}}) do
    user = get_session(conn, :user)
    up_to = String.to_integer(up_to)

    {:ok, %{id: id}} = GameManager.create_game(name, user, up_to)

    redirect(conn, to: game_path(conn, :show, id, user: user))
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
