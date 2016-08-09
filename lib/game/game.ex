defmodule Reactor.Game do
  use GenServer
  alias Reactor.RefHelper
  alias Reactor.RoundSupervisor

  ##Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  ##Server Callbacks

  def init(name) do
    state = %{
      users: %{},
      current_round: nil,
      game_id: RefHelper.to_id(name),
    }

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

    {:reply, {:ok, user}, state}
  end

  def handle_call({:current_round}, _from, %{current_round: current_round} = state) do
    {:reply, {:ok, current_round}, state}
  end

  def handle_cast({:start_game}, state) do
    GenServer.cast(self, {:start_round})
    {:noreply, state}
  end

  def handle_cast({:start_round}, %{users: users, game_id: game_id} = state) do
    users = Enum.map(users, fn({user, _}) -> user end)
    :timer.sleep(3000)
    {:ok, pid} = RoundSupervisor.start_round(RefHelper.to_round_sup_ref(game_id), users)

    {:noreply, put_in(state, [:current_round], pid)}
  end

  def handle_cast({:submit_answer, %{answer: answer, user: user, et: et}}, %{current_round: current_round} = state) do
    GenServer.cast(current_round, {:submit_answer, %{answer: answer, user: user, et: et}})

    {:noreply, state}
  end
end
