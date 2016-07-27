defmodule Reactor.GameManagerTest do
  use ExUnit.Case, async: true

  test "can create and get games" do
    assert Enum.count(Reactor.GameManager.get_games) == 0

    {id, pid} = Reactor.GameManager.create_game

    assert Enum.count(Reactor.GameManager.get_games) == 1
    assert Enum.take(Reactor.GameManager.get_games, 1) == [{id, pid}]
  end

  test "adds users to games" do
    {id, pid} = Reactor.GameManager.create_game
    {:ok, users} = Reactor.GameManager.get_users(id)
    assert Enum.count(users) == 0

    Reactor.GameManager.add_user_to_game(id, "User")
    {:ok, users} = Reactor.GameManager.get_users(id)

    assert Enum.count(users) == 1
  end
end
