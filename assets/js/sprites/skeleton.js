export default {
  name: 'skeleton',
  sheet: '/images/monster4.png',
  frameWidth: 120,
  frameHeight: 128,
  default_animation: 'skeleton_idle',
  animationList: ['skeleton_idle', 'skeleton_walk_up', 'skeleton_walk_down', 'skeleton_walk_left', 'skeleton_walk_right'],
  animations: {
    skeleton_idle: {
      frames: [9, 10, 11],
      frameRate: 3,
      repeat: -1
    },
    skeleton_walk_down: {
      frames: [9, 10, 11],
      frameRate: 6,
      repeat: -1
    },
    skeleton_walk_left: {
      frames: [21, 22, 23],
      frameRate: 6,
      repeat: -1
    },
    skeleton_walk_right: {
      frames: [33, 34, 35],
      frameRate: 6,
      repeat: -1
    },
    skeleton_walk_up: {
      frames: [45, 46, 47],
      frameRate: 6,
      repeat: -1
    },
  }
}
