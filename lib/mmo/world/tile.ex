defmodule Mmo.World.Tile do
  @derive Jason.Encoder
  defstruct [:npc, position: 129, collision: false]

  def gen_tile_map(jsonMapData) do
    height = jsonMapData["height"]
    width = jsonMapData["width"]

    map =
      Enum.reduce(jsonMapData["layers"], %{}, fn %{"name" => name, "data" => data} = _tile, map ->
        updated_data = Enum.map(data, fn tile -> tile - 1 end)
        Map.put(map, String.to_atom(name), Enum.chunk_every(updated_data, width))
      end)

    Map.merge(map, %{height: height, width: width})
  end
end
