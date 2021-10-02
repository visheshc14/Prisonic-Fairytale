defmodule Mmo.Player do
  alias Mmo.Player
  alias Mmo.Player.Controller
  alias Mmo.World

  @derive Jason.Encoder
  defstruct id: "",
            name: "",
            x: 64,
            y: 64,
            attack: 10,
            max_health: 100,
            health: 100,
            exp: 0,
            required_exp: 25,
            level: 0,
            type: ""

  def hit(damage, %Player{health: health} = defender) do
    %{defender | health: health - damage}
  end

  @spec move(%Player{} | nil, :up | :down | :left | :right | map) ::
          %Player{}
  def move(%Player{x: current_x, y: current_y} = player, %{x: new_x, y: new_y}) do
    x = update_cord(current_x, new_x)
    y = update_cord(current_y, new_y)
    %{player | x: x, y: y}
  end

  def move(%Player{} = player, :error) do
    player
  end

  def move(player, data) do
    move(player, Controller.convert(data))
  end

  def increase_exp(
        %Player{exp: exp, required_exp: required_exp} = player,
        increase_amount
      ) do
    new_exp = exp + increase_amount

    if new_exp >= required_exp do
      left_over_exp = new_exp - required_exp
      level(player, left_over_exp)
    else
      %{player | exp: new_exp}
    end
  end

  def level(
        %Player{
          attack: attack,
          required_exp: required_exp,
          level: level,
          max_health: max_health
        } = player,
        exp
      ) do
    new_health = max_health + 50

    %{
      player
      | level: level + 1,
        attack: attack + 1,
        exp: exp,
        required_exp: required_exp * 2,
        health: new_health,
        max_health: new_health
    }
  end

  def new(%World{player_ids: player_ids} = world) do
    {x, y} = World.get_random_cords(world)
    %Player{id: generate_uuid(player_ids), x: x, y: y}
  end

  def new(%{id: player_id, x: x, y: y}) do
    %Player{id: player_id, x: x, y: y}
  end

  def new(%Player{id: player_id}, %World{} = world) do
    {x, y} = World.get_random_cords(world)
    %Player{id: player_id, x: x, y: y}
  end

  defp generate_uuid(player_ids) do
    uuid = Ecto.UUID.generate()
    generate_uuid(Enum.member?(player_ids, uuid), uuid, player_ids)
  end

  defp generate_uuid(true, _uuid, player_ids) do
    generate_uuid(player_ids)
  end

  defp generate_uuid(false, uuid, _player_ids) do
    uuid
  end

  defp update_cord(current, new) when current > new do
    current - 1
  end

  defp update_cord(current, new) when current < new do
    current + 1
  end

  defp update_cord(current, _new) do
    current
  end

  def damage(%Player{health: health} = player, damage_amount) do
    %{player | health: health - damage_amount}
  end

  def damagePercent(%Player{max_health: max_health} = player, percent) do
    damage(player, max_health * percent)
  end

  def respawn(%Player{health: health} = player, %World{} = _world) when health > 0 do
    player
  end

  def respawn(%Player{} = player, %World{} = world) do
    Player.new(player, world)
  end
end
