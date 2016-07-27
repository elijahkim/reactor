defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end

  def join("game:" <> game_id, message, socket) do
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end
end
