defmodule Reactor.GameManagerTest do
  use ExUnit.Case, async: true
  alias Reactor.GameManager

  setup do
    {:ok, %{name: name, id: id}} = GameManager.create_game(:Test, "Owner")

    {:ok, %{name: name, id: id}}
  end

  test "can create, get games, and see the game's owner", %{name: name} do
    {:ok, games} = GameManager.get_games

    fetched_game =
      games
      |> Enum.find(fn game -> game.name == name end)

    assert fetched_game.owner == "Owner"
  end

  test "can get a particular game", %{id: id, name: name} do
    {:ok, game} = GameManager.get_game(id)

    assert game.name == name
  end

  test "adds users to games", game do
    {:ok, users} = GameManager.get_users(game.id)
    assert Enum.count(users) == 0

    {:ok, users} = GameManager.add_user_to_game(game.id, "User")

    assert Enum.count(users) == 1
  end

  test "removes users from games", game do
    GameManager.add_user_to_game(game.id, "User")
    {:ok, users} = GameManager.get_users(game.id)
    assert Enum.count(users) == 1

    {:ok, users} = GameManager.remove_user_from_game(game.id, "User")

    assert Enum.count(users) == 0
  end

  test "Only the game owner can start the game", game do
    GameManager.add_user_to_game(game.id, "User")

    {:error, "Must be owner"} = GameManager.start_game(game.id, "User")
    :ok = GameManager.start_game(game.id, "Owner")

    {:ok, round} = GameManager.get_current_round(game.id)
    assert is_pid(round)
  end

  test "readys users in a game", game do
    GameManager.start_game(game.id, "Owner")
    GameManager.add_user_to_game(game.id, "User")
    {:ok, %{"User" => user}} = GameManager.get_users(game.id)

    refute user[:ready]

    GameManager.ready_user(game.id, "User")
    {:ok, %{"User" => user}} = GameManager.get_users(game.id)

    assert user[:ready]
  end
end
