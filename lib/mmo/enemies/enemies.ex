defmodule Mmo.Enemies do
  use GenServer

  alias Mmo.{Player, World, Collision, Item}

  @max_enemy_moves 10000

  def start_link(world \\ []) do
    GenServer.start_link(__MODULE__, world, name: Mmo.Enemies)
  end

  @impl true
  def init(_enemy_ids) do
    {:ok, []}
  end

  @impl true
  def handle_info(:tick, enemy_ids) do
    world = GenServer.call(GameWorld, {:get_state})
    move(enemy_ids, world)
    schedule_work()
    {:noreply, enemy_ids}
  end

  @impl true
  def handle_cast({:add, enemies}, enemy_ids) do
    new_enemy_ids = Enum.map(enemies, fn %{id: enemy_id} -> enemy_id end)
    {:noreply, List.flatten(new_enemy_ids, enemy_ids)}
  end

  @impl true
  def handle_call({:respawn, enemy_id, %World{enemies: enemies} = world}, _from, enemy_ids) do
    updated_enemies = Map.put(enemies, enemy_id, new(enemy_id, world))
    {:reply, %{world | enemies: updated_enemies}, enemy_ids}
  end

  def handle_call({:gen, %World{} = world, enemy_count}, _from, _enemy_ids) do
    {new_enemy_ids, enemies} = gen_enemies(world, enemy_count)
    schedule_work()
    {:reply, enemies, new_enemy_ids}
  end

  def handle_call({:gen, _world, _enemy_count}, _from, _enemy_ids) do
    {:reply, %{}, []}
  end

  def gen_enemies(world, enemy_count) do
    enemies =
      Enum.reduce(0..enemy_count, %{}, fn _, acc ->
        enemy = new(world)
        Map.put(acc, enemy.id, enemy)
      end)

    enemy_ids =
      enemies
      |> Map.values()
      |> Enum.map(fn %{id: enemy_id} -> enemy_id end)

    {enemy_ids, enemies}
  end

  def new(enemy_id, %World{} = world) do
    enemy_type =
      Enum.random([
        Mmo.Enemies.Snake,
        Mmo.Enemies.Snake,
        Mmo.Enemies.Snake,
        Mmo.Enemies.Snake,
        Mmo.Enemies.Skeleton,
        Mmo.Enemies.Skeleton,
        Mmo.Enemies.Skeleton,
        Mmo.Enemies.Skeleton,
        Mmo.Enemies.Wizard
      ])

    enemy_type.new(enemy_id, World.get_random_cords(world))
  end

  def new(%World{} = world) do
    enemy_id = Ecto.UUID.generate()
    new(enemy_id, world)
  end

  def damage(%{type: %{health: health}} = enemy, %Player{attack: attack}) do
    %{enemy | health: health - attack}
  end

  def damage(
        %{health: health, id: enemy_id, exp: exp, item: item} = enemy,
        %{attack: attack} = player,
        %World{} = world
      ) do
    updated_health = health - attack

    if updated_health > 0 do
      {%{enemy | health: updated_health}, player}
    else
      updated_player =
        player
        |> Item.apply_effect(item)
        |> Player.increase_exp(exp)

      {new(enemy_id, world), updated_player}
    end
  end

  def move(enemy_ids, %World{enemies: enemies} = world) when is_list(enemy_ids) do
    Enum.take_random(enemy_ids, @max_enemy_moves)
    |> Enum.map(fn enemy_id ->
      enemy = Map.get(enemies, enemy_id)
      move(enemy, world)
    end)
  end

  def move(enemy, %World{players: players} = world) do
    updated_enemy = gen_random_move(enemy, world)
    action = hit_player(enemy, Map.values(players), updated_enemy)

    case action do
      {:update_enemy, {:no_collision, {:damage_object, _tile_number}}} ->
        # Damage tile
        # GenServer.cast(GameWorld, {})
        :ok

      {:enemy_hit_player, enemy, updated_player} ->
        GenServer.cast(GameWorld, {:enemy_hit_player, enemy, updated_player})

      {:update_enemy, updated_enemy} ->
        GenServer.cast(GameWorld, {:update_enemy, updated_enemy})
    end
  end

  def gen_random_move(
        %{x: x, y: y, x_moves: x_moves, y_moves: y_moves, targeting: nil} = enemy,
        %World{} = world
      ) do
    new_x = x + Enum.random(x_moves)
    new_y = y + Enum.random(y_moves)
    updated_enemy = %{enemy | x: new_x, y: new_y}
    attempt_move(enemy, world, updated_enemy)
  end

  def gen_random_move(%{targeting: player_id} = enemy, %World{players: players} = world) do
    player = Map.get(players, player_id)

    if player != nil and should_target_player?(enemy, player) do
      updated_enemy = move_to_player(enemy, player)
      attempt_move(enemy, world, updated_enemy)
    else
      gen_random_move(%{enemy | targeting: nil}, world)
    end
  end

  def attempt_move(enemy, world, updated_enemy) do
    case Collision.check(updated_enemy, world) do
      {:collision, :static_object} ->
        enemy

      {:no_collision, {:damage_object, _}} ->
        enemy

      _ ->
        updated_enemy
    end
  end

  def hit_player(_enemy, [], updated_enemy) do
    {:update_enemy, updated_enemy}
  end

  def hit_player(
        %{attack: attack} = enemy,
        [%Player{x: x, y: y, id: player_id} = player | _players],
        %{
          x: x,
          y: y
        }
      ) do
    updated_player = Player.hit(attack, player)
    updated_enemy = %{enemy | targeting: player_id}
    {:enemy_hit_player, updated_enemy, updated_player}
  end

  def hit_player(enemy, [%{id: player_id} = player | players], updated_enemy) do
    if should_target_player?(enemy, player) do
      hit_player(%{enemy | targeting: player_id}, players, %{updated_enemy | targeting: player_id})
    else
      hit_player(enemy, players, updated_enemy)
    end
  end

  def move_to_player(%{x: x, y: y} = enemy, %Player{
        x: player_x,
        y: player_y,
        id: player_id
      }) do
    new_x = move_to_cord(x, player_x)
    new_y = move_to_cord(y, player_y)

    %{enemy | x: new_x, y: new_y, targeting: player_id}
  end

  def move_to_cord(enemy_cord, player_cord) when enemy_cord > player_cord do
    enemy_cord - 1
  end

  def move_to_cord(enemy_cord, player_cord) when enemy_cord < player_cord do
    enemy_cord + 1
  end

  def move_to_cord(cord, cord) do
    cord
  end

  def should_target_player?(%{x: x, y: y, targeting_range: range, targeting: nil}, %{
        x: player_x,
        y: player_y
      }) do
    (x + range > player_x and x < player_x) or (x - range < player_x and x > player_x) or
      (y + range > player_y and y < player_y) or (y - range < player_y and y > player_y)
  end

  def should_target_player?(%{x: x, y: y, targeting_range: range, targeting: player_id}, %{
        x: player_x,
        y: player_y,
        id: player_id
      }) do
    (x + range > player_x and x < player_x) or (x - range < player_x and x > player_x) or
      (y + range > player_y and y < player_y) or (y - range < player_y and y > player_y)
  end

  def should_target_player?(_, _) do
    false
  end

  def get(%{x: x, y: y}, enemies) do
    enemies
    |> Enum.at(y)
    |> Enum.at(x)
  end

  defp schedule_work() do
    Process.send_after(self(), :tick, 1000)
  end
end
