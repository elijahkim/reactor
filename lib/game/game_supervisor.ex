defmodule Reactor.GameSupervisor do
  use Supervisor
  alias Reactor.RefHelper

  @name __MODULE__

  ##Client API

  def start_link(name, up_to) do
    Supervisor.start_link(@name, [name, up_to], name: name)
  end

  ##Server callbacks

  def init([name, up_to]) do
    id = RefHelper.to_id(name)

    children = [
      worker(Reactor.Game, [RefHelper.to_game_ref(id), up_to]),
      supervisor(Reactor.RoundSupervisor, [RefHelper.to_round_sup_ref(id)]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
