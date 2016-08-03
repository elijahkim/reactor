defmodule Reactor.UserController do
  use Reactor.Web, :controller

  def create(conn, %{"user" => %{"name" => name}}) do
    conn = put_session(conn, :user, name)

    redirect(conn, to: game_path(conn, :index))
  end
end
