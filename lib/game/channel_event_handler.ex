alias Experimental.GenStage

defmodule Reactor.ChannelEventHandler do
  use GenStage
  alias Reactor.GameChannel

  @name __MODULE__

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Reactor.EventManager]}
  end

  def handle_event({:new_round, %{game_id: game_id, colors: colors, instruction: instruction}}) do
    GameChannel.broadcast_new_round(game_id, %{colors: colors, instruction: instruction})
  end

  def handle_event({:round_handled, %{winner: winner, game_id: game_id}}) do
    GameChannel.broadcast_winner(game_id, %{user: winner})
  end

  def handle_event({:round_handled, %{game_id: game_id}}) do
    GameChannel.broadcast_winner(game_id, %{user: "No one"})
  end

  def handle_event({:new_game, _state}) do
    GameChannel.broadcast_games
  end

  def handle_event(_) do
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
