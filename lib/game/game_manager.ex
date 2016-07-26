defmodule Reactor.GameManager do
  use GenServer
  @name __MODULE__

  ##client API

  def start_link do
    GenServer.start_link(@name, :ok, name: @name)
  end

  def create_game do
    Reactor.Random.random_string(10)
    |> create_game
  end

  defp create_game(id) do
    GenServer.call(@name, {:add_game, id})
  end

  def get_games do
    GenServer.call(@name, {:get_games})
  end

  ##server callbacks

  def init(:ok) do
    state = %{games: %{}}

    {:ok, state}
  end

  def handle_call({:add_game, id},_, state) do
    {:ok, pid} = Reactor.GameSupervisor.create_game
    {
      :reply,
      %{id => pid},
      put_in(state, [:games, id], pid)
    }
  end

  def handle_call({:get_games},_, state) do
    {:reply, state.games, state}
  end
end
