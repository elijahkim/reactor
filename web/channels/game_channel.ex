defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end

  def join("game:" <> game_id, message, socket) do
    send(self, {:after_join, message})
    send(self, {:user_update, message})

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end

  def handle_info({:user_update, message}, socket) do
    broadcast(socket, "new:user_update", %{count: 0})

    {:noreply, socket}
  end
end
