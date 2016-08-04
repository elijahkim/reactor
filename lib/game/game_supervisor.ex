defmodule Reactor.GameSupervisor do
  use Supervisor
  alias Reactor.RefHelper

  @name __MODULE__

  ##client API

  def start_link(name) do
    Supervisor.start_link(@name, name, name: name)
  end

  ##server callbacks

  def init(name) do
    id = RefHelper.to_id(name)

    children = [
      worker(Reactor.Game, [RefHelper.to_game_ref(id)]),
      supervisor(Reactor.RoundSupervisor, [RefHelper.to_round_sup_ref(id)]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
