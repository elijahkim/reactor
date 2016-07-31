defmodule Reactor.GameChannelTest do
  use Reactor.ChannelCase

  @endpoint Reactor.Endpoint

  test "can start a game" do
    Reactor.GameManager.create_game("hello")

    {:ok, _, socket} =
      socket("game:hello", %{user: "eli"})
      |> subscribe_and_join(Reactor.GameChannel, "game:hello")

    push(socket, "start_game", %{})
    assert_broadcast "new:round", %{"colors" => _, "instruction" => _}
  end
end
