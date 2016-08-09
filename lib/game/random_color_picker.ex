defmodule Reactor.RandomColorPicker do
  @colors ["red", "green", "yellow", "blue", "orange", "pink"]

  def get_colors do
    colors = Enum.take_random(@colors, 4)
    instruction = Enum.random(colors)

    {colors, instruction}
  end
end
