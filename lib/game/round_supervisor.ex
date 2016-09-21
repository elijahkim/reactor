defmodule Reactor.RoundSupervisor do
  use Supervisor
  alias Reactor.RefHelper

  ##Client API

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def start_round(ref, users) do
    game_id = RefHelper.to_id(ref)

    Supervisor.start_child(ref, [game_id, users])
  end

  ##Server Callbacks

  def init(:ok) do
    children = [
      worker(Reactor.Round, [], restart: :transient),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
