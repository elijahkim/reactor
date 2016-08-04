defmodule Reactor.RefHelperTest do
  use ExUnit.Case, async: true

  test "turns a string of id to an atom to find a game" do
    id = "hello"
    ref = Reactor.RefHelper.to_game_ref(id)

    assert ref == :"hello---game"
  end

  test "turns a string of id to an atom to find a round supervisor" do
    id = "hello"
    ref = Reactor.RefHelper.to_round_sup_ref(id)

    assert ref == :"hello---round-sup"
  end

  test "turns a string of id to an atom to find a game supervisor" do
    id = "hello"
    ref = Reactor.RefHelper.to_game_sup_ref(id)

    assert ref == :"hello---game-sup"
  end

  test "turns any ref to a id string" do
    ref = :"hello---round-sup"
    id = Reactor.RefHelper.to_id(ref)

    assert id == "hello"

    ref = :"hello world---round-sup"
    id = Reactor.RefHelper.to_id(ref)

    assert id == "hello world"
  end
end
