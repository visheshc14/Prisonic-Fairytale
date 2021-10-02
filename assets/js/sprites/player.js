export default {
  name: 'player',
  sheet: '/images/chara7.png',
  frameWidth: 52,
  frameHeight: 72,
  default_animation: 'player_idle',
  animationList: ['player_idle', 'player_walk_up', 'player_walk_down', 'player_walk_left', 'player_walk_right'],
  animations: {
    player_idle: {
      frames: [3, 4, 5],
      frameRate: 3,
      repeat: -1
    },
    player_walk_down: {
      frames: [3, 4, 5],
      frameRate: 6,
      repeat: -1
    },
    player_walk_up: {
      frames: [39, 40, 41],
      frameRate: 6,
      repeat: -1
    },
    player_walk_right: {
      frames: [27, 28, 29],
      frameRate: 6,
      repeat: -1
    },
    player_walk_left: {
      frames: [15, 16, 17],
      frameRate: 6,
      repeat: -1
    },
  }
}
