export default {
  name: 'wizard',
  sheet: '/images/wizard.png',
  frameWidth: 52,
  frameHeight: 72,
  default_animation: 'wizard_idle',
  animationList: ['wizard_idle', 'wizard_walk_up', 'wizard_walk_down', 'wizard_walk_left', 'wizard_walk_right'],
  animations: {
    wizard_idle: {
      frames: [0, 1, 2],
      frameRate: 3,
      repeat: -1
    },
    wizard_walk_down: {
      frames: [0, 1, 2],
      frameRate: 6,
      repeat: -1
    },
    wizard_walk_left: {
      frames: [12, 13, 14],
      frameRate: 6,
      repeat: -1
    },
    wizard_walk_right: {
      frames: [24, 25, 26],
      frameRate: 6,
      repeat: -1
    },
    wizard_walk_up: {
      frames: [36, 37, 38],
      frameRate: 6,
      repeat: -1
    },
  }
}
