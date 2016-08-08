defmodule Reactor.GameManagerTest do
  use ExUnit.Case, async: true
  alias Reactor.GameManager

  setup do
    {:ok, %{name: name, id: id}} = GameManager.create_game

    {:ok, %{name: name, id: id}}
  end

  test "can create and get games", game do
    {:ok, games} = GameManager.get_games

    assertion =
      games
      |> Enum.map(fn game -> game.name end)
      |> Enum.find(fn n -> n == game.name end)

    assert assertion
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

  test "starts a round per game", game do
    GameManager.add_user_to_game(game.id, "User")

    :ok = GameManager.start_round(game.id)
    {:ok, round} = GameManager.get_current_round(game.id)

    assert is_pid(round)
  end
end
