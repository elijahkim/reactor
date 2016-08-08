defmodule Reactor.GameChannelTest do
  use Reactor.ChannelCase

  @endpoint Reactor.Endpoint

  test "can start a game" do
    {:ok, %{id: id}} = Reactor.GameManager.create_game

    {:ok, _, socket} =
      socket("game:#{id}", %{user: "eli"})
      |> subscribe_and_join(Reactor.GameChannel, "game:#{id}")

    push(socket, "start_game", %{})
    assert_broadcast "new:round", %{colors: _, instruction: _}
  end
end
