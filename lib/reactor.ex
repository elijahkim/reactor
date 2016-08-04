defmodule Reactor do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Reactor.Repo, []),
      supervisor(Reactor.Endpoint, []),
      worker(Reactor.GameManager, []),
      supervisor(Reactor.GamesSupervisor, []),
      worker(Reactor.EventManager,  []),
      worker(Reactor.ChannelEventHandler, []),
      worker(Reactor.GamesEventHandler, []),
    ]

    opts = [strategy: :one_for_one, name: Reactor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Reactor.Endpoint.config_change(changed, removed)
    :ok
  end
end
