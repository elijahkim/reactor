defmodule Reactor.GamesSupervisor do
  use Supervisor
  alias Reactor.RefHelper

  @name __MODULE__

  ##Client API

  def start_link do
    Supervisor.start_link(@name, :ok, name: @name)
  end

  def create_game(name) do
    Supervisor.start_child(@name, [RefHelper.to_game_sup_ref(name)])
  end

  ##Server callbacks

  def init(:ok) do
    children = [
      supervisor(Reactor.GameSupervisor, []),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
