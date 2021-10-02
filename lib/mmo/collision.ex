defmodule Mmo.Collision do
  alias Mmo.{World, Player}

  def check(%{x: x, y: y}, %World{width: width, height: height})
      when x < 0 or y < 0 or x >= width or y >= height do
    {:collision, :static_object}
  end

  def check(%Player{} = player, %World{} = world) do
    if collision_check(player, world) do
      {:collision, :static_object}
    else
      case damage_check(player, world) do
        false ->
          case enemy_check(player, world) do
            false ->
              case item_check(player, world) do
                false ->
                  :no_collision

                {true, item} ->
                  {:collision, {:item, item}}
              end

            {true, enemy} ->
              {:collision, {:enemy, enemy}}
          end

        tile_number ->
          {:no_collision, {:damage_object, tile_number}}
      end
    end
  end

  def check(%{} = player, %World{} = world) do
    if collision_check(player, world) do
      {:collision, :static_object}
    else
      case damage_check(player, world) do
        false ->
          case enemy_check(player, world) do
            false ->
              :no_collision

            {true, enemy} ->
              {:collision, {:enemy, enemy}}
          end

        tile_number ->
          {:no_collision, {:damage_object, tile_number}}
      end
    end
  end

  def check(_obj, _checking_objs) do
    :no_collision
  end

  def collision_check(%{} = player, %World{collision: collision}) do
    get_tile_data(player, collision) > 0
  end

  def damage_check(%{} = player, %World{damage: damage_tiles}) do
    tile_number = get_tile_data(player, damage_tiles)

    if get_tile_data(player, damage_tiles) > 0 do
      {true, tile_number}
    else
      false
    end
  end

  def enemy_check(%{} = player, %World{enemies: enemies}) do
    enemy_check(player, Map.values(enemies))
  end

  def enemy_check(_player, []) do
    false
  end

  def enemy_check(%{x: x, y: y}, [%{x: x, y: y} = enemy | _enemies]) do
    {true, enemy}
  end

  def enemy_check(player, [_enemy | enemies]) do
    enemy_check(player, enemies)
  end

  def item_check(%{} = player, %World{items: items}) do
    item_check(player, Map.values(items))
  end

  def item_check(_player, []) do
    false
  end

  def item_check(%{x: x, y: y}, [%{x: x, y: y} = enemy | _enemies]) do
    {true, enemy}
  end

  def item_check(player, [_enemy | enemies]) do
    item_check(player, enemies)
  end

  def get_tile_data(%{x: x, y: y}, tiles) when is_list(tiles) do
    tiles
    |> Enum.at(y)
    |> Enum.at(x)
  end
end
