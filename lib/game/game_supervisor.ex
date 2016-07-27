defmodule Reactor.GameSupervisor do
  use Supervisor
  @name __MODULE__

  ##client API

  def start_link do
    Supervisor.start_link(@name, :ok, name: @name)
  end

  def create_game do
    Supervisor.start_child(@name, [])
  end

  ##server callbacks

  def init(:ok) do
    children = [
      worker(Reactor.Game, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
