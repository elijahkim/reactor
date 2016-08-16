defmodule Reactor.GameManager do
  use GenServer
  alias Reactor.RefHelper

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
    |> RefHelper.to_game_ref
    |> GenServer.call({:get_users})
  end

  def add_user_to_game(game_id, user) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.call({:add_user, user})
  end

  def remove_user_from_game(game_id, user) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.call({:remove_user, user})
  end

  def ready_user(game_id, user) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.call({:ready_user, user})
  end

  def start_game(game_id) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.cast({:start_game})
  end

  def start_round(game_id) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.cast({:start_round})
  end

  def get_current_round(game_id) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.call({:current_round})
  end

  def submit_answer(game_id, user, answer, et) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.cast({:submit_answer, %{user: user, answer: answer, et: et}})
  end

  def handle_winner(game_id, winner) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.cast({:handle_winner, %{winner: winner}})
  end

  def handle_no_winner(game_id) do
    game_id
    |> RefHelper.to_game_ref
    |> GenServer.cast({:handle_no_winner})
  end

  ##server callbacks

  def init(:ok) do
    state = %{games: []}

    {:ok, state}
  end

  def handle_call({:add_game, name}, _from, %{games: games} = state) do
    game_id = Enum.count(games) + 1
    {:ok, _pid} = Reactor.GamesSupervisor.create_game(game_id)
    game = %{name: name, id: game_id}
    games = games ++ [game]

    {:reply, {:ok, game}, put_in(state, [:games], games)}
  end

  def handle_call({:get_games}, _from, %{games: games} = state) do
    {:reply, {:ok, games}, state}
  end
end
