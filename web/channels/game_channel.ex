defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", message, socket) do
    {:ok, socket}
  end
end
