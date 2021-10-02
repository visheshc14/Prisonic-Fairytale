defmodule Mmo.Item do
  alias Mmo.Player
  alias HealthPot

  def apply_effect(%Player{} = player, %{item: nil}) do
    player
  end

  def apply_effect(%Player{} = player, %{item: item}) do
    apply_effect(player, item)
  end

  def apply_effect(%Player{} = player, nil) do
    player
  end

  def apply_effect(%Player{health: player_health, max_health: max_health} = player, %{
        affect: :heal,
        modifier: modifier
      }) do
    updated_health = player_health + modifier

    if updated_health < max_health do
      %{player | health: player_health + modifier}
    else
      %{player | health: max_health}
    end
  end
end
