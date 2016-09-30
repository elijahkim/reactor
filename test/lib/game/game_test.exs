defmodule Reactor.GameTest do
  use ExUnit.Case, async: true
  alias Reactor.{GamesSupervisor, Game, GameFSM}

  setup do
    name = "test"
    {:ok, pid} = GamesSupervisor.create_game(name, 1)

    state = %{
      users: %{"eli" => %{score: 0}},
      current_round: nil,
      game_id: name,
      up_to: 2,
      game_state: GameFSM.new
    }

    on_exit fn ->
      Supervisor.terminate_child(GamesSupervisor, pid)
    end

    {:ok, %{state: state}}
  end

  test "initializes with game state" do
    {:ok, %{game_state: game_state}} = Game.init([:test, 1])

    assert game_state == GameFSM.new
  end

  test "state is 'game_starting' when the game starts", %{state: state} do
    {:reply, _, %{game_state: game_state}} =
      Game.handle_call({:start_game}, :hi, state)

    assert game_state.state == :game_starting
  end

  test "state is 'round_in_progress' when the round starts", %{state: state} do
    %{game_state: game_state} = state
    new_game_state = game_state |> GameFSM.start
    state = Map.put(state, :game_state, new_game_state)

    {:noreply, %{game_state: game_state}} =
      Game.handle_cast({:start_round}, state)

    assert game_state.state == :round_in_progress
    assert game_state.data == 1
  end

  test "state is 'round_finished' when the round ends and a winner isn't found", %{state: state} do
    %{game_state: game_state} = state
    new_game_state =
      game_state
      |> GameFSM.start
      |> GameFSM.stage_round
      |> GameFSM.start_round
    state = Map.put(state, :game_state, new_game_state)

    {:noreply, %{game_state: game_state}} =
      Game.handle_cast({:handle_winner, %{winner: "eli"}}, state)

    assert game_state.state == :round_finished
  end

  test "state is 'game_over' when the winner is found", %{state: state} do
    %{game_state: game_state} = state
    new_game_state =
      game_state
      |> GameFSM.start
      |> GameFSM.stage_round
      |> GameFSM.start_round
    state =
      state
      |> Map.put(:game_state, new_game_state)
      |> Map.put(:up_to, 1)

    {:noreply, %{game_state: game_state}} =
      Game.handle_cast({:handle_winner, %{winner: "eli"}}, state)

    assert game_state.state == :game_over
  end
end
