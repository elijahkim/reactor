defmodule Reactor.GameChannel do
  use Phoenix.Channel
  alias Reactor.GameManager
  require Logger

  def join("game", _message, socket) do
    {:ok, socket}
  end

  def join("game:" <> game_id, message, socket) do
    %{user: user} = socket.assigns

    {:ok, users, socket} = add_user_and_game(%{game_id: game_id, user: user}, socket)

    send(self, {:after_join, message})
    send(self, {:user_update, users})

    {:ok, socket}
  end

  def terminate(reason, socket) do
    %{user: user, game_id: game_id} = socket.assigns

    {:ok, users} = GameManager.remove_user_from_game(game_id, user)
    broadcast(socket, "new:user_update", %{users: users})
    :ok
  end

  def handle_in("new:user_ready", msg, socket) do
    %{user: user, game_id: game_id} = socket.assigns

    {:ok, %{name: name}} = GameManager.ready_user(game_id, user)

    broadcast(socket, "new:message", %{message: "#{name} is ready"})
    {:noreply, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end

  def handle_info({:user_update, users}, socket) do
    broadcast(socket, "new:user_update", %{users: users})
    {:noreply, socket}
  end

  defp add_user_and_game(%{game_id: game_id, user: user}, socket) do
    socket =
      socket
      |> assign(:user, user)
      |> assign(socket, :game_id, game_id)

    {:ok, users} = GameManager.add_user_to_game(game_id, user)

    {:ok, users, socket}
  end
end
