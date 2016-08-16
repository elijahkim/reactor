defmodule Reactor.GameChannel do
  use Phoenix.Channel
  alias Reactor.GameManager
  require Logger

  def broadcast_new_round(game_id, msg) do
    Reactor.Endpoint.broadcast("game:#{game_id}", "new:round", msg)
  end

  def broadcast_winner(game_id, %{user: user}) do
    {:ok, users} = GameManager.get_users(game_id)
    Reactor.Endpoint.broadcast("game:#{game_id}", "new:winner", %{user: user, users: users})
  end

  def broadcast_games do
    {:ok, games} = GameManager.get_games
    Reactor.Endpoint.broadcast("game:lobby", "new:game_update", %{games: games})
  end

  def join("game:lobby", _message, socket) do
    send(self, {:broadcast_games})

    {:ok, socket}
  end

  def join("game:" <> game_id, message, socket) do
    %{user: user} = socket.assigns

    {:ok, users, socket} = add_user_and_game(%{game_id: game_id, user: user}, socket)

    send(self, {:after_join, message})
    send(self, {:user_update, users})

    {:ok, socket}
  end

  def terminate(_reason, %{assigns: %{user: user, game_id: game_id}} = socket) do
    {:ok, users} = GameManager.remove_user_from_game(game_id, user)
    broadcast(socket, "new:user_update", %{users: users})
    :ok
  end

  def terminate(_, socket) do
    :ok
  end

  def handle_in("new:user_ready", _msg, socket) do
    %{user: user, game_id: game_id} = socket.assigns

    {:ok, %{name: name}} = GameManager.ready_user(game_id, user)

    broadcast(socket, "new:message", %{message: "#{name} is ready"})
    {:noreply, socket}
  end

  def handle_in("start_game", _msg, socket) do
   %{game_id: game_id} = socket.assigns
   GameManager.start_game(game_id)

   {:noreply, socket}
  end

  def handle_in("new:answer_submission", %{"submission" => submission, "et" => et}, socket) do
    %{user: user, game_id: game_id} = socket.assigns
    GameManager.submit_answer(game_id, user, submission, et)

    {:noreply, socket}
  end

  def handle_in("new:winner_received", _msg, socket) do
    %{user: user, game_id: game_id} = socket.assigns
    GameManager.ready_user(game_id, user)

    {:noreply, socket}
  end

  def handle_info({:after_join, _msg}, socket) do
    push(socket, "new:message", %{message: "Welcome! Please wait for users to join"})

    {:noreply, socket}
  end

  def handle_info({:user_update, users}, socket) do
    broadcast(socket, "new:user_update", %{users: users})
    {:noreply, socket}
  end

  def handle_info({:broadcast_games}, socket) do
    {:ok, games} = GameManager.get_games
    broadcast(socket, "new:game_update", %{games: games})

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
