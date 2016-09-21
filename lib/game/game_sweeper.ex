defmodule Reactor.GameSweeper do
  use GenServer
  alias Reactor.{RefHelper, GameManager}
  @interval 5000

  ##Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  ##Server Callbacks

  def init(:ok) do
    :timer.send_interval(@interval, :sweep)

    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    {:ok, games} = GameManager.get_games

    Enum.each(games, &process_game/1)

    {:noreply, state}
  end

  defp process_game(%{id: game_id}) do
    {:ok, users} = GameManager.get_users(game_id)

    case map_size(users) do
      0 -> stop_game(game_id)
      _ -> nil
    end
  end

  defp stop_game(game_id) do
    game_id
    |> RefHelper.to_game_sup_ref
    |> Supervisor.stop(:shutdown)
  end
end
