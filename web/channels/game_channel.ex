defmodule Reactor.GameChannel do
  use Phoenix.Channel
  alias Reactor.GameManager
  require Logger

  def broadcast_new_round(topic, msg) do
    Reactor.Endpoint.broadcast("game:#{topic}", "new:round", msg)
  end

  def broadcast_winner(topic, %{user: user} = msg) do
    Reactor.Endpoint.broadcast("game:#{topic}", "new:message", %{message: "#{user} is the winner!"})
  end

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

  def handle_in("start_game", msg, socket) do
   %{game_id: game_id} = socket.assigns
   GameManager.start_game(game_id)

   {:noreply, socket}
  end

  def handle_in("new:answer_submission", %{"submission" => submission} = msg, socket) do
    %{user: user, game_id: game_id} = socket.assigns
    GameManager.submit_answer(game_id, user, submission)

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
      |> assign(:game_id, game_id)

    {:ok, users} = GameManager.add_user_to_game(game_id, user)

    {:ok, users, socket}
  end
end
