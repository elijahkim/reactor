defmodule RoundTest do
  use ExUnit.Case, async: true

  test "start_link/1 takes users and sets state" do
    users = ["Tim", "Eli"]
    {:ok, pid} = Reactor.Game.Round.start_link(users)
    assert is_pid(pid)
  end

  test "submit/2 takes pid and guess" do
    users = ["Tim", "Eli"]
    {:ok, pid} = Reactor.Game.Round.start_link(users)
    {response} = Reactor.Game.Round.submit(pid, %{"Tim" => %{guess: "red", et: 1000}})

    assert response == :ok
  end
end
