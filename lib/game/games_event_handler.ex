alias Experimental.GenStage

defmodule Reactor.GamesEventHandler do
  use GenStage
  alias Reactor.GameManager

  @name __MODULE__

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Reactor.EventManager]}
  end

  def handle_event({:winner, %{game_id: game_id}}) do
    GameManager.start_round(game_id)
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
