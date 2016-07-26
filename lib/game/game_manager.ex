defmodule Reactor.GameManager do
  use GenServer
  @name __MODULE__

  ##client API

  def start_link do
    GenServer.start_link(@name, :ok, name: @name)
  end

  def create_game(id) do
    GenServer.cast(@name, {:add_game, id})
  end

  ##server callbacks

  def init(:ok) do
    state = %{games: %{}}

    {:ok, state}
  end

  def handle_cast({:add_game}, state) do
    {:ok, pid} = Reactor.GameSupervisor.create_game
    {:noreply, Map.put}
  end
end
