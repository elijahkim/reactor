defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end
end
