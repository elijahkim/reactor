defmodule Reactor.Game.Round do
  use GenServer

  @colors ["red", "green", "yellow", "blue", "orange", "pink"]

  ##Client API

  def start_link(game_id, users) do
    GenServer.start_link(__MODULE__, [game_id, users])
  end

  ##Server Callbacks

  def init([game_id, users]) do
    state =
      users
      |> Enum.map(fn(user) -> {user, %{guess: nil, et: nil}} end)
      |> Enum.into(%{})
      |> Map.put(:game_id, Atom.to_string(game_id))

    GenServer.cast(self, {:start_round})
    {:ok, state}
  end

  def handle_cast({:start_round}, state) do
    colors = Enum.take_random(@colors, 4)
    instruction = Enum.random(colors)

    state =
      state
      |> Map.put(:colors, colors)
      |> Map.put(:instruction, instruction)

    Reactor.Game.EventManager.fire_event({:new_round, state})

    {:noreply, state}
  end
end
