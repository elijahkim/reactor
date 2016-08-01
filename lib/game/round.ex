defmodule Reactor.Game.Round do
  use GenServer

  @colors ["red", "green", "yellow", "blue", "orange", "pink"]

  def start_link(game_id, users) do
    GenServer.start_link(__MODULE__, [game_id, users])
  end

  def submit(_hello, _world) do
    {:ok}

    # update_state
    # check state
    # if everyone submitted
    # emit event
  end

  ##Server Callbacks

  def init([game_id, users]) do
    #get random colors
    #set it in state
    #emit to game_event_manager
    colors = Enum.take_random(@colors, 4)
    instruction = Enum.random(colors)

    state =
      users
      |> Enum.map(fn(user) -> {user, %{guess: nil, et: nil}} end)
      |> Enum.into(%{})
      |> Map.put(:colors, colors)
      |> Map.put(:instruction, instruction)
      |> Map.put(:game_id, Atom.to_string(game_id))

    Reactor.Game.EventManager.fire_event({:new_round, state})
    {:ok, state}
  end
end
