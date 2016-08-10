defmodule Reactor.RandomColorPicker do
  @colors [
    "blue",
    "brown",
    "green",
    "orange",
    "pink",
    "purple",
    "red",
    "yellow",
  ]

  def get_colors do
    colors = Enum.take_random(@colors, 4)
    instruction = Enum.random(colors)

    {colors, instruction}
  end
end
