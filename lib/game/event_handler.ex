alias Experimental.GenStage

defmodule Reactor.Game.EventHandler do
  use GenStage
  alias Reactor.GameChannel
  alias Reactor.GameManager

  @name __MODULE__

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Reactor.Game.EventManager]}
  end

  def handle_event({:new_round, %{game_id: game_id, colors: colors, instruction: instruction}}) do
    game_id = game_id |> String.replace_leading("game-", "")

    GameChannel.broadcast_new_round(game_id, %{colors: colors, instruction: instruction})
  end

  def handle_event({:winner, %{user: user, game_id: game_id}}) do
    game_id = game_id |> String.replace_leading("game-", "")

    GameChannel.broadcast_winner(game_id, %{user: user})
    GameManager.start_round(game_id)
  end

  def handle_events([event|events], from, state) do
    handle_event(event)
    handle_events(events, from, state)

    {:noreply, [], state}
  end

  def handle_events([], _from, state) do
    {:noreply, [], state}
  end
end
