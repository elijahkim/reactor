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

  def handle_call({:get_users}, _from, state) do
    {:reply, {:ok, state.users}, state}
  end

  def handle_cast({:add_user, user}, state) do
    {:noreply, put_in(state, [:users, user], %{score: 0})}
  end
end
