defmodule Reactor.GameSupervisorTest do
  use ExUnit.Case, async: true

  test "can create a game" do
    %{workers: workers} = Supervisor.count_children(Reactor.GameSupervisor)
    assert workers == 0

    {status, _pid} = Reactor.GameSupervisor.create_game

    %{workers: workers} = Supervisor.count_children(Reactor.GameSupervisor)
    assert workers == 1
    assert status == :ok
  end
end
