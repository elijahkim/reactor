defmodule Reactor.GameManagerTest do
  use ExUnit.Case, async: true
  alias Reactor.GameManager

  test "can create and get games" do
    {:ok, games} = GameManager.get_games
    assert Enum.count(games) == 0

    {id, pid} = GameManager.create_game

    {:ok, games} = GameManager.get_games
    assert Enum.count(games) == 1
    assert Enum.take(GameManager.get_games, 1) == [{id, pid}]
  end

  test "adds users to games" do
    {id, _pid} = GameManager.create_game
    {:ok, users} = GameManager.get_users(id)
    assert Enum.count(users) == 0

    {:ok, users} = GameManager.add_user_to_game(id, "User")

    assert Enum.count(users) == 1
  end

  test "removes users from games" do
    {id, _pid} = GameManager.create_game
    GameManager.add_user_to_game(id, "User")
    {:ok, users} = GameManager.get_users(id)
    assert Enum.count(users) == 1

    {:ok, users} = GameManager.remove_user_from_game(id, "User")

    assert Enum.count(users) == 0
  end

  test "readys users on games" do
    {id, _pid} = GameManager.create_game
    GameManager.add_user_to_game(id, "User")
    {:ok, %{"User" => user}} = GameManager.get_users(id)
    assert user.ready == false

    {:ok, user} = GameManager.ready_user(id, "User")

    assert user.ready == true
  end
end
