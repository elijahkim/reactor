defmodule Reactor.Game do
  use GenServer

  ##client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  ##Server Callbacks

  def init(:ok) do
    state = %{}

    {:ok, state}
  end
end
