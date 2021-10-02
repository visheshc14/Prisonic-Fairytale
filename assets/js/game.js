import socket from "./socket";
import Sprites from './sprites';
import Player from './users/player'
import Players from './users/players';
import Enemies from './enemies';
import HUD from './hud';
import Item from './items';

// Load a map from a 2D array of tile indices
// W16 X H13
let game = null;
let background;
let foreground;
let items;
let leaf;
let user;
let userData;
const players = new Players();
const enemies = new Enemies();
const width = 16;
const height = 12;
const spriteSize = 64;
let pointerRect;
// game = new Phaser.Game(config);

// Char is W21 X H14

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})

channel.on("update_world", payload => {
  // console.log('UpdateWorld', payload)
})

channel.on("new_player", data => {
  // console.log('NewPlayer', data);
  if (userData.id != data.player.id) {
    players.newPlayer(data.player);
  }
})

channel.on("player_update", data => {
  // console.log('PlayerUpdate', data);
  if (data.player.id == userData.id) {
    user.updateData(data.player);
  } else {
    players.updatePlayer(data.player);
  }
});

channel.on("enemy_update", data => {
  // console.log("Enemy Update", data);
  enemies.updateEnemy(data.enemy);
});

channel.on("enemy_hit_player", data => {
  // console.log("Enemy Hit Player", data);
  if (data.player.id == userData.id) {
    user.updateData(data.player)
  } else {
    players.updatePlayer(data.player)
  }
});

channel.on("player_attack", data => {
  // console.log("Player Attack", data);
  if (data.player.id == userData.id) {
    user.updateData(data.player)
  } else {
    players.updatePlayer(data.player)
  }
  enemies.updateEnemy(data.enemy);
});

channel.on("player_left", data => {
  // console.log('PlayerLeft', data);
  players.removePlayer(data.player_id);
})

channel.on("player_hit", data => {
  // console.log('PlayerHit', data);
  data.players.map(playerData => {
    if (userData.id == playerData.id) {
      user.updateData(playerData);
    } else {
      players.updatePlayer(playerData)
    }
  })
})

channel.on("item", data => {
  console.log("Item", data)
  if (userData.id == data.player.id) {
    user.updateData(data.player);
  } else {
    players.updatePlayer(data.player)
  }
  items[0].x = data.item.x * 32;
  items[0].y = data.item.y * 32;
});

channel.join()
  .receive("ok", resp => {
    // console.log("Joined successfully", resp);
    background = resp.background;
    foreground = resp.foreground;
    items = resp.items;
    leaf = resp.leaf;

    // Create Player and add them to the players obj
    userData = resp.player;
    players.userId = userData.id;
    players.unrenderedPlayers = resp.players.filter(playerData => playerData.id !== userData.id);

    // Add Enemies
    enemies.userId = userData.id;
    console.warn(resp.enemies);
    enemies.unrenderedEnemies = resp.enemies;
    game = new Phaser.Game(config);
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

var config = {
  type: Phaser.AUTO,
  width: width * spriteSize,
  height: height * spriteSize,
  useTicker: true,
  scene: [{
    key: 'GameScene',
    preload: preload,
    create: create,
    update: update
  }, HUD]
};

function preload() {
  this.load.image('worldTiles', '/images/tilemap.png');
  this.load.image('items', '/images/randomitems.png');

  // Loading all sprites used for the game
  Sprites.spriteList.map(spriteName => {
    const sprite = Sprites.data[spriteName];
    this.load.spritesheet(
      sprite.name,
      sprite.sheet,
      { frameWidth: sprite.frameWidth, frameHeight: sprite.frameHeight });
  });
}

function create() {
  this.input.setDefaultCursor('url(images/Cursor2.cur), pointer');

  // Setup world map
  const tileSet = 'worldTiles';
  background = this.make.tilemap({ data: background, tileWidth: 32, tileHeight: 32 });
  background.addTilesetImage('worldTiles');
  background.createStaticLayer(0, tileSet, 0, 0)

  // Adds animations to sprites
  Sprites.addAnimations.call(this, Sprites.spriteList, Sprites.data)

  leaf = this.make.tilemap({ data: leaf, tileWidth: 32, tileHeight: 32 });
  leaf.addTilesetImage(tileSet);
  leaf.createStaticLayer(0, tileSet, 0, 0);

  this.input.on('pointerdown', function (pointer) {
    channel.push("pointer_down", { player_id: userData.id, x: Math.floor(pointer.worldX / 32), y: Math.floor(pointer.worldY / 32) });
  });
  this.input.keyboard.on('keydown', (event) => {
    // channel.push("key_down", { key: event.key });
  });

  foreground = this.make.tilemap({ data: foreground, tileWidth: 32, tileHeight: 32 });
  foreground.addTilesetImage('worldTiles');
  foreground.createStaticLayer(0, tileSet, 0, 0)

  items = items.map(item => new Item(this, item));

  pointerRect = this.add.rectangle(0, 0, 32, 32);
  this.input.on('pointermove', function (pointer) {
    pointerRect.x = Math.floor(pointer.worldX / 32) * 32;
    pointerRect.y = Math.floor(pointer.worldY / 32) * 32;
    pointerRect.setStrokeStyle(2, 0x1a65ac);
    pointerRect.setOrigin(0, 0);
  }, this);

  // Adds the current user to the canvas
  user = new Player(this, userData);

  // Create camera
  const camera = this.cameras.main.setSize(width * spriteSize, height * spriteSize);
  camera.startFollow(user);

}

function update(time) {
  if (user.data.get('isMoving')) {
    user.movePlayer();
  } else {
    // user.movePlayer();
  }
  // if (players.moves.dirty) {
  //   players.moves.list.map(player => {
  //     player.movePlayer();
  //   });
  //   players.moves.dirty = false;
  //   players.moves.list = [];
  // }
  players.renderPlayers(this);
  players.removePlayers();
  enemies.renderEnemy(this);
  enemies.removeEnemies();
  this.events.emit('updateHUD', user);
}