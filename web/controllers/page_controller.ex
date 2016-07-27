defmodule Reactor.PageController do
  use Reactor.Web, :controller

  def index(conn, _params) do
    {:ok, games} = Reactor.GameManager.get_games

    render(conn, "index.html", games: Map.keys(games))
  end
end
