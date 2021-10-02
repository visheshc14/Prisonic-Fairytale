defmodule Mmo.GameWorld do
  use GenServer

  @enemy_count 100

  alias Mmo.{Collision, Player, World, Enemies}
  alias Mmo.Item.PsycoMedic

  def start_link(world \\ []) do
    GenServer.start_link(__MODULE__, world, name: GameWorld)
  end

  @impl true
  def init(_world) do
    world = World.gen("")
    Process.send_after(self(), {:add_enemies}, 1)
    {:ok, world}
  end

  @impl true
  def handle_call({:new_player}, _from, %World{} = world) do
    player = Player.new(world)
    updated_world = World.add_player(player, world)
    {:reply, {player, updated_world}, updated_world}
  end

  def handle_call(
        {:move_player, %{player_id: player_id, x: _x, y: _y} = data},
        _from,
        %World{enemies: enemies, players: players, items: items} = world
      ) do
    player = World.get_player(player_id, world)
    updated_player = Player.move(player, data)

    case Collision.check(updated_player, world) do
      {:collision, :static_object} ->
        {:reply, {:static_object, {"player_update", player}}, world}

      {:no_collision, {:damage_object, tile_number}} ->
        damaged_player =
          case tile_number do
            {true, 120} ->
              Player.damagePercent(updated_player, 1)

            _ ->
              Player.damagePercent(updated_player, 0.35)
          end

        respawned_player = Player.respawn(damaged_player, world)

        respawned =
          damaged_player.x != respawned_player.x and damaged_player.y != respawned_player.y

        {:reply, {"player_update", respawned_player, respawned},
         World.update(respawned_player, world)}

      :no_collision ->
        {:reply, {"player_update", updated_player, false}, World.update(updated_player, world)}

      {:collision, {:item, %{id: item_id} = item}} ->
        new_item = PsycoMedic.new(id: item_id)

        updated_player = PsycoMedic.apply_effect(updated_player, item)
        respawned_player = Player.respawn(updated_player, world)

        respawned =
          updated_player.x != respawned_player.x and updated_player.y != respawned_player.y

        updated_items = Map.put(items, item_id, new_item)
        updated_players = Map.put(players, player_id, respawned_player)

        updated_world = %{world | items: updated_items, players: updated_players}

        {:reply, {"item", respawned_player, new_item, respawned}, updated_world}

      {:collision, {:enemy, %{id: enemy_id} = enemy}} ->
        {updated_enemy, %{id: player_id} = updated_player} = Enemies.damage(enemy, player, world)
        updated_enemies = Map.put(enemies, enemy_id, updated_enemy)
        updated_players = Map.put(players, player_id, updated_player)

        {:reply, {"player_attack", updated_player, updated_enemy},
         %{world | enemies: updated_enemies, players: updated_players}}
    end
  end

  def handle_call({:get_state}, _from, world) do
    {:reply, world, world}
  end

  @impl true
  def handle_cast({:remove_player, player_id}, %World{} = world) do
    {:noreply, World.remove_player(player_id, world)}
  end

  @impl true
  def handle_cast(
        {:update_enemy, %{id: enemy_id} = enemy},
        %World{enemies: enemies} = world
      ) do
    updated_enemies = Map.put(enemies, enemy_id, enemy)

    MmoWeb.Endpoint.broadcast!("room:lobby", "enemy_update", %{
      enemy: enemy
    })

    {:noreply, %{world | enemies: updated_enemies}}
  end

  def handle_cast(
        {:enemy_hit_player, enemy, %{id: player_id} = player},
        %World{players: players} = world
      ) do
    updated_player = Player.respawn(player, world)
    updated_players = Map.put(players, player_id, updated_player)

    MmoWeb.Endpoint.broadcast!("room:lobby", "enemy_hit_player", %{
      enemy: enemy,
      player: updated_player
    })

    {:noreply, %{world | players: updated_players}}
  end

  @impl true
  def handle_info({:add_enemies}, %World{} = world) do
    enemies = GenServer.call(Enemies, {:gen, world, @enemy_count - 1})
    {:noreply, %{world | enemies: enemies}}
  end
end
