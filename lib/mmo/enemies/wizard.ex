defmodule Mmo.Enemies.Wizard do
  alias Mmo.Enemies.Wizard
  alias Mmo.Item.HealthPot

  @derive Jason.Encoder
  defstruct [
    :id,
    :x,
    :y,
    :attack,
    :max_health,
    :health,
    :exp,
    :level,
    :item,
    :targeting,
    targeting_range: 4,
    name: "Wizard",
    sprite: "wizard",
    x_moves: [-1, 0, 0, 0, 1],
    y_moves: [-1, 0, 0, 0, 1]
  ]

  def new(cords) do
    new(Ecto.UUID.generate(), cords)
  end

  def new(uuid, {x, y}) do
    level = Enum.random(3..10)
    modifier = Enum.random([2, 2.5, 3, 3.5, 4, 4.5])
    max_health = 100 * modifier + level
    item = Enum.random([nil, nil, HealthPot, HealthPot])
    sprite = "wizard"

    if item != nil do
      %Wizard{
        id: uuid,
        x: x,
        y: y,
        level: level,
        attack: 6 * modifier + level,
        max_health: max_health,
        health: max_health,
        exp: 100 * level,
        item: item.new(),
        sprite: sprite
      }
    else
      %Wizard{
        id: uuid,
        x: x,
        y: y,
        level: level,
        attack: 3 * modifier + level,
        max_health: max_health,
        health: max_health,
        exp: 10 * level,
        sprite: sprite
      }
    end
  end
end
