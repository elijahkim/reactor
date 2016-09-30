defmodule Reactor.Game do
  use GenServer
  alias Reactor.{RefHelper, RoundSupervisor, EventManager, GameFSM}

  ##Client API

  def start_link(name, up_to) do
    GenServer.start_link(__MODULE__, [name, up_to], name: name)
  end

  ##Server Callbacks

  def init([name, up_to]) do
    state = %{
      users: %{},
      current_round: nil,
      game_id: RefHelper.to_id(name),
      up_to: up_to,
      game_state: GameFSM.new
    }

    GenServer.cast(self, {:broadcast_init})

    {:ok, state}
  end

  def handle_call({:get_users}, _from, %{users: users} = state) do
    {:reply, {:ok, users}, state}
  end

  def handle_call({:add_user, user}, _from, %{users: users} = state) do
    users = Map.put(users, user, %{name: user, score: 0, ready: false})

    {:reply, {:ok, users}, Map.put(state, :users, users)}
  end

  def handle_call({:remove_user, user}, _from, state) do
    {_, %{users: users} = state} = pop_in(state, [:users, user])

    {:reply, {:ok, users}, state}
  end

  def handle_call({:ready_user, user}, _from, state) do
    state = put_in(state, [:users, user, :ready], true)
    %{users: %{^user => user}} = state

    if all_users_ready?(state) do
      GenServer.cast(self, {:start_round})
    end

    {:reply, {:ok, user}, state}
  end

  def handle_call({:current_round}, _from, %{current_round: current_round} = state) do
    {:reply, {:ok, current_round}, state}
  end

  def handle_call({:start_game}, _from, %{game_state: game_state} = state) do
    state = Map.put(state, :game_state, GameFSM.start(game_state))

    {:reply, GenServer.cast(self, {:start_round}), state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:broadcast_init}, state) do
    Reactor.EventManager.fire_event({:new_game, state})

    {:noreply, state}
  end

  def handle_cast({:start_round}, %{current_round: nil} = state) do
    {:noreply, start_round(state)}
  end

  def handle_cast({:start_round}, %{current_round: current_round} = state) do
    {:noreply, state}
  end

  def handle_cast({:submit_answer,
    %{answer: answer, user: user, et: et}},
    %{current_round: current_round} = state) do

    GenServer.cast(current_round, {:submit_answer, %{answer: answer, user: user, et: et}})

    {:noreply, state}
  end

  def handle_cast({:handle_winner, %{winner: winner}}, %{game_state: game_state} = state) do
    {_, state} = get_and_update_in(state, [:users, winner, :score], &{&1, &1 + 1})
    case match_ended?(state) do
      false ->
        EventManager.fire_event({:round_handled, Map.put(state, :winner, winner)})
        new_game_state = GameFSM.finish_round(game_state)
        new_state =
          state
          |> reset_state
          |> Map.put(:game_state, new_game_state)
        {:noreply, new_state}
      nil ->
        EventManager.fire_event({:round_handled, Map.put(state, :winner, winner)})
        new_game_state = GameFSM.finish_round(game_state)
        new_state =
          state
          |> reset_state
          |> Map.put(:game_state, new_game_state)
        {:noreply, new_state}
      winner ->
        EventManager.fire_event({:game_over, Map.put(state, :winner, winner)})
        new_game_state =
          game_state
          |> GameFSM.finish_round
          |> GameFSM.finish_game
        new_state =
          state
          |> reset_state
          |> Map.put(:game_state, new_game_state)
        {:noreply, new_state}
    end
  end

  def handle_cast({:handle_no_winner}, state) do
    EventManager.fire_event({:round_handled, state})

    {:noreply, reset_state(state)}
  end

  defp start_round(%{users: users, game_id: game_id, game_state: game_state} = state) do
    :timer.sleep(3000)
    users = Enum.map(users, fn({user, _}) -> user end)
    {:ok, pid} =
      game_id
      |> RefHelper.to_round_sup_ref
      |> RoundSupervisor.start_round(users)
    new_game_state =
      game_state
      |> GameFSM.stage_round
      |> GameFSM.start_round

    state
    |> put_in([:current_round], pid)
    |> put_in([:game_state], new_game_state)
  end

  defp reset_state(state) do
    state
    |> unready_all_users
    |> empty_current_round
  end

  defp empty_current_round(state) do
    put_in(state, [:current_round], nil)
  end

  defp unready_all_users(%{users: users} = state) do
    users =
      users
      |> Enum.map(fn {name, user} -> {name, put_in(user, [:ready], false)} end)
      |> Enum.into(%{})

    put_in(state, [:users], users)
  end

  defp all_users_ready?(%{users: users} = state) do
    Enum.all?(users, fn {_name, user} -> user[:ready] end)
  end

  defp match_ended?(%{users: users, up_to: up_to}) do
    if up_to > 0 do
      Enum.find(users, fn {_, %{score: score}} -> score >= up_to end)
    else
      false
    end
  end
end
