export default {
  name: 'snake',
  sheet: '/images/monster1.png',
  frameWidth: 120,
  frameHeight: 128,
  default_animation: 'snake_idle',
  animationList: ['snake_idle', 'snake_walk_up', 'snake_walk_down', 'snake_walk_left', 'snake_walk_right'],
  animations: {
    snake_idle: {
      frames: [51, 52, 53],
      frameRate: 3,
      repeat: -1
    },
    snake_walk_down: {
      frames: [51, 52, 53],
      frameRate: 6,
      repeat: -1
    },
    snake_walk_left: {
      frames: [63, 64, 65],
      frameRate: 6,
      repeat: -1
    },
    snake_walk_right: {
      frames: [75, 76, 77],
      frameRate: 6,
      repeat: -1
    },
    snake_walk_up: {
      frames: [87, 97, 99],
      frameRate: 6,
      repeat: -1
    },
  }
}
