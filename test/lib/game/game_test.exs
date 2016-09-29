defmodule Reactor.GameTest do
  use ExUnit.Case, async: true
  alias Reactor.{GamesSupervisor, Game, GameFSM}

  setup do
    name = "test"
    GamesSupervisor.create_game(name, 1)

    state = %{
      users: %{},
      current_round: nil,
      game_id: name,
      up_to: 1,
      game_state: GameFSM.new
    }

    {:ok, %{state: state}}
  end

  test "initializes with game state" do
    {:ok, %{game_state: game_state}} = Game.init([:test, 1])

    assert game_state == GameFSM.new
  end

  test "state is 'starting' when the game starts", %{state: state} do
    {:reply, _, %{game_state: game_state}} =
      Game.handle_call({:start_game}, :hi, state)

    assert game_state.state == :starting
  end

  test "state is 'in_round' when the round starts", %{state: state} do
    %{game_state: game_state} = state
    new_game_state = game_state |> GameFSM.start
    state = Map.put(state, :game_state, new_game_state)

    {:noreply, %{game_state: game_state}} =
      Game.handle_cast({:start_round}, state)

    assert game_state.state == :in_round
  end
end
