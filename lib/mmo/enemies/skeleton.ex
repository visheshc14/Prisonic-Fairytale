defmodule Mmo.Enemies.Skeleton do
  alias Mmo.Enemies.Skeleton
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
    name: "Skeleton",
    sprite: "skeleton",
    x_moves: [-1, 0, 0, 0, 1],
    y_moves: [-1, 0, 0, 0, 1]
  ]

  def new(cords) do
    new(Ecto.UUID.generate(), cords)
  end

  def new(uuid, {x, y}) do
    level = Enum.random(1..5)
    modifier = Enum.random([1, 1.5, 2, 2.5, 3, 3.5])
    max_health = 30 * modifier + level
    item = Enum.random([nil, nil, nil, HealthPot])

    if item != nil do
      %Skeleton{
        id: uuid,
        x: x,
        y: y,
        level: level,
        attack: 3 * modifier + level,
        max_health: max_health,
        health: max_health,
        exp: 10 * level,
        item: item.new()
      }
    else
      %Skeleton{
        id: uuid,
        x: x,
        y: y,
        level: level,
        attack: 3 * modifier + level,
        max_health: max_health,
        health: max_health,
        exp: 10 * level
      }
    end
  end
end
