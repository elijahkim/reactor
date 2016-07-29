defmodule Reactor.GameController do
  use Reactor.Web, :controller
  alias Reactor.GameManager

  def index(conn, _params) do
    {:ok, games} = GameManager.get_games
    user = get_session(conn, :user)

    render(conn, "index.html", games: Map.keys(games), user: user)
  end

  def create(conn, %{"game" => %{"name" => name}} = params) do
    {id, _pid} = GameManager.create_game(name)
    user = get_session(conn, :user)

    redirect(conn, to: game_path(conn, :show, id, user: user))
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html")
  end
end
