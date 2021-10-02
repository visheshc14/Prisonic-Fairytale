defmodule Mmo.World do
  alias Mmo.{World, Player, Collision}
  alias Mmo.World.Tile
  alias Mmo.Item.PsycoMedic

  @width 10
  @height 10

  @derive Jason.Encoder
  defstruct key: "world_map",
            file: "",
            players: %{},
            background: [],
            foreground: [],
            leaf: [],
            collision: [],
            damage: [],
            items: %{},
            spawned_items: [],
            enemies: %{},
            player_ids: [],
            map: [],
            width: @width,
            height: @height

  def gen(_file) do
    # Replace with read from file
    world_data =
      "test3.json"
      |> File.read!()
      |> Jason.decode!()
      |> Tile.gen_tile_map()

    world = struct(World, world_data)

    %{id: psyco_medic_id} = psyco_medic = PsycoMedic.new()
    items = Map.put(%{}, psyco_medic_id, psyco_medic)

    %{world | items: items}
  end

  @spec update(%Tile{} | %Player{} | [%Player{}], %World{}) :: %World{}
  def update(%Tile{} = tile, %World{map: map} = world, tile_x, tile_y) do
    updated_columns =
      map
      |> Enum.at(tile_y)
      |> List.replace_at(tile_x, tile)

    updated_tiles = List.replace_at(map, tile_y, updated_columns)
    %{world | tiles: updated_tiles}
  end

  def update(%Player{id: player_id, health: health} = player, %World{players: players} = world)
      when health > 0 do
    updated_players = Map.put(players, player_id, player)
    %{world | players: updated_players}
  end

  def update(%Player{id: player_id} = player, %World{players: players} = world) do
    updated_players = Map.put(players, player_id, player)
    %{world | players: updated_players}
  end

  def update([], %World{} = world) do
    world
  end

  def update([%{id: player_id} = player | t], %World{players: players} = world) do
    updated_players = Map.put(players, player_id, player)
    update(t, %{world | players: updated_players})
  end

  def add_player(
        %Player{id: player_id} = player,
        %World{players: players, player_ids: player_ids} = world
      ) do
    updated_players = Map.put(players, player_id, player)
    %{world | players: updated_players, player_ids: [player_id | player_ids]}
  end

  def remove_player(
        player_id,
        %World{players: players, player_ids: player_ids} = world
      ) do
    {_, updated_players} = Map.pop(players, player_id)
    updated_player_ids = Enum.filter(player_ids, fn p_id -> p_id != player_id end)
    %{world | players: updated_players, player_ids: updated_player_ids}
  end

  @spec get_player(String.t(), %World{}) :: %Player{}
  def get_player(player_id, %World{players: players}) do
    Map.get(players, player_id)
  end

  @spec get_random_cords(integer, integer) :: {integer, integer}
  def get_random_cords(width, height) do
    {:rand.uniform(width - 1), :rand.uniform(height - 1)}
  end

  def get_random_cords(%World{width: width, height: height} = world) do
    x = :rand.uniform(width - 1)
    y = :rand.uniform(height - 1)
    cords = %{x: x, y: y}

    case Collision.check(cords, world) do
      :no_collision ->
        {x, y}

      _ ->
        get_random_cords(world)
    end
  end
end
