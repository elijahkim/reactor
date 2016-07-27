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

  def create_game(id) do
    GenServer.call(@name, {:add_game, id})
  end

  def get_games do
    GenServer.call(@name, {:get_games})
  end

  def get_users(game_id) do
    game_id
    |> to_ref
    |> GenServer.call({:get_users})
  end

  def add_user_to_game(game_id, user) do
    game_id
    |> to_ref
    |> GenServer.call({:add_user, user})
  end

  def to_ref(id) do
    :"game-#{id}"
  end

  ##server callbacks

  def init(:ok) do
    state = %{games: %{}}

    {:ok, state}
  end

  def handle_call({:add_game, id}, _from, state) do
    {:ok, pid} = Reactor.GameSupervisor.create_game(to_ref(id))
    {:reply, {id, pid}, put_in(state, [:games, id], pid)}
  end

  def handle_call({:get_games}, _from, %{games: games} = state) do
    {:reply, {:ok, games}, state}
  end
end
