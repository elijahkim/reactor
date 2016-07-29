defmodule Reactor.Game do
  use GenServer

  ##client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  ##Server Callbacks

  def init(:ok) do
    state = %{
      users: %{}
    }

    {:ok, state}
  end

  def handle_call({:get_users}, _from, %{users: users} = state) do
    {:reply, {:ok, users}, state}
  end

  def handle_call({:add_user, user}, _from, %{users: users} = state) do
    users = Map.put(users, user, %{name: user, score: 0})

    {:reply, {:ok, users}, Map.put(state, :users, users)}
  end

  def handle_call({:remove_user, user}, _from, state) do
    {_, %{users: users} = state} = pop_in(state, [:users, user])

    {:reply, {:ok, users}, state}
  end
end
