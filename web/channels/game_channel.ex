defmodule Reactor.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end

  def join("game:" <> game_id, %{"user" => user} = message, socket) do
    Reactor.GameManager.add_user_to_game(game_id, user)
    send(self, {:after_join, message})
    send(self, {:user_update, game_id, message})

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end

  def handle_info({:user_update, game_id, message}, socket) do
    {:ok, users} = Reactor.GameManager.get_users(game_id)
    broadcast(socket, "new:user_update", %{users: users})

    {:noreply, socket}
  end
end
