defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end

  def join("game:" <> game_id, %{"user" => user} = message, socket) do
    {:ok, users} = Reactor.GameManager.add_user_to_game(game_id, user)

    send(self, {:after_join, message})
    send(self, {:user_update, users})

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end

  def handle_info({:user_update, users}, socket) do
    broadcast(socket, "new:user_update", %{users: users})
    {:noreply, socket}
  end
end
