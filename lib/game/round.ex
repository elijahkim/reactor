defmodule Reactor.Game.Round do
  use GenServer

  def start_link(users) do
    GenServer.start_link(__MODULE__, users)
  end

  def submit(_hello, _world) do
    {:ok}

    # update_state
    # check state
    # if everyone submitted
    # emit event
  end

  ##Server Callbacks

  def init(users) do
    state =
      users
      |> Enum.map(fn(user) -> {user, %{guess: nil, et: nil}} end)
      |> Enum.into(%{})

    {:ok, state}
  end
end
