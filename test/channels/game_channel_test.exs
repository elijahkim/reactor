defmodule Reactor.GameChannelTest do
  use Reactor.ChannelCase, async: true

  @endpoint Reactor.Endpoint

  test "can start a game" do
    name = "#{:rand.uniform(10)}-test"
    {:ok, %{id: id}} = Reactor.GameManager.create_game(name, "Owner")

    {:ok, _, socket} =
      socket("game:#{id}", %{user: "Owner"})
      |> subscribe_and_join(Reactor.GameChannel, "game:#{id}")

    push(socket, "start_game", %{})
    assert_broadcast("new:round", %{colors: _, instruction: _}, 4000)
  end
end
