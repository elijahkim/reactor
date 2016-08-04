defmodule Reactor.RefHelper do
  def to_game_ref(id) do
    :"#{id}---game"
  end

  def to_game_sup_ref(id) do
    :"#{id}---game-sup"
  end

  def to_round_sup_ref(id) do
    :"#{id}---round-sup"
  end

  def to_id(ref) do
    ref
    |> Atom.to_string
    |> String.split("---")
    |> Enum.fetch!(0)
  end
end
