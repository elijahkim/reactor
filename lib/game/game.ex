defmodule Reactor.Game do
  use GenServer

  ##Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  ##Server Callbacks

  def init(:ok) do
    state = %{
      users: %{},
      current_round: nil,
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

  def handle_cast({:start_round}, %{users: users} = state) do
    {:ok, pid} = Reactor.Game.Round.start_link(Enum.map(users, &(&1.name)))
    {:noreply, put_in(state, [:current_round], pid)}
  end

  def handle_call({:current_round}, _from, %{current_round: current_round} = state) do

    {:reply, {:ok, current_round}, state}
  end
end
