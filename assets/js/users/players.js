import Player from './player';

export default class Players {
  constructor(playersData, userId) {
    this.data = {};
    this.ids = [];
    this.unrenderedPlayers = playersData || [];
    this.destroyList = [];
    this.userId = userId || null;
    this.moves = { list: [], dirty: false };
    // this.addPlayers(playersData);
  }

  newPlayer(playerData) {
    this.unrenderedPlayers.push(playerData);
  }

  renderPlayers(scene) {
    const length = this.unrenderedPlayers.length;
    if (length > 0) {
      let newPlayer;
      for (let i = 0; i < length; i++) {
        newPlayer = new Player(scene, this.unrenderedPlayers[i]);
        this.addPlayer(newPlayer);
      }
      this.unrenderedPlayers = [];
    }
  }

  removePlayer(id) {
    // Failing to remove players at the moment
    const player = this.data[id];
    if (player != undefined) {
      this.ids.filter(playerId => playerId != id)
      player.removeAll();
      player.destroy(true);
      delete this.data[id];
    } else {
      console.error(`ID is missing ${id}`)
    }
  }

  removePlayers() {
    this.destroyList.forEach(playerId => this.removePlayer(playerId));
    this.destroyList = [];
  }

  addPlayer(player) {
    const playerId = player.data.get('id')
    if (playerId != this.userId) {
      this.data[playerId] = player;
      this.ids.push(playerId);
      return player;
    }
    return null;
  }

  updatePlayer(playerData) {
    const player = this.data[playerData.id];
    player.updateData(playerData);
  }
}