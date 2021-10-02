class Map {
  constructor(map, tileSet) {
    this.map = map;
    this.tileSet = map.addTilesetImage(tileSet);
    this.layers = [map.createStaticLayer(0, tileSet, 0, 0)];
  }
}

export default Map;