defmodule Reactor.GameSupervisorTest do
  use ExUnit.Case, async: true

  test "can create a game" do
    %{workers: workers} = Supervisor.count_children(Reactor.GameSupervisor)
    assert workers == 0

    {:ok, _pid} = Reactor.GameSupervisor.create_game(:hello)

    %{workers: workers} = Supervisor.count_children(Reactor.GameSupervisor)
    assert workers == 1
  end
end
