defmodule Reactor.GameManagerTest do
  use ExUnit.Case, async: true

  test "can create and get games" do
    assert Enum.count(Reactor.GameManager.get_games) == 0

    {id, pid} = Reactor.GameManager.create_game

    assert Enum.count(Reactor.GameManager.get_games) == 1
    assert Enum.take(Reactor.GameManager.get_games, 1) == [{id, pid}]
  end
end
