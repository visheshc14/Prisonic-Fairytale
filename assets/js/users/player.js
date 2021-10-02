import HealthBar from './health_bar';
import { sprites } from '../sprites';

export default class Player extends Phaser.GameObjects.Container {
  constructor(scene, playerData) {
    const updated_x = playerData.x * 32;
    const updated_y = playerData.y * 32;
    super(scene, updated_x, updated_y);

    const spriteName = playerData.sprite || 'player';
    const frameHeight = sprites[spriteName].frameHeight;

    this.scene = scene;
    this.sprite = scene.add.sprite(0, 0, spriteName);
    this.sprite.setOrigin(0.14, 0.5);
    this.sprite.setScale(64 / frameHeight);
    this.sprite.play(`${spriteName}_idle`);


    this.setDataEnabled();
    this.setData({
      id: playerData.id,
      health: playerData.health || 100,
      maxHealth: playerData.max_health || 100,
      exp: playerData.exp || 0,
      isMoving: false,
      spriteName: spriteName,
      defaultAnimation: 'idle',
      currentAnimation: 'idle',
      speed: Phaser.Math.GetSpeed(200, 3),
      level: playerData.level || 0,
      name: playerData.name || playerData.id.split('-').pop(),
      playerType: playerData.type || ""
    });

    this.healthBar = new HealthBar(scene, playerData.health, playerData.max_health);
    this.add([this.sprite, this.healthBar]);
    // this.add([this.sprite, this.healthBar]);
    this.scene.add.container(0, 0, this).setExclusive(true);
  }

  play(animationName) {
    if (this.data.get('currentAnimation') == animationName) {
      return;
    }
    this.data.set('currentAnimation', animationName);
    this.sprite.play(`${this.data.get('spriteName')}_${animationName}`);
  }

  updatePosition({ x: x, y: y }) {
    const updatedX = x * 32;
    const updatedY = y * 32;

    if (this.x < updatedX) {
      this.play('walk_right');
    } else if (this.x > updatedX) {
      this.play('walk_left');
    } else if (this.y > updatedY) {
      this.play('walk_up');
    } else if (this.y < updatedY) {
      this.play('walk_down');
    } else {
      this.play('idle');
    }

    this.x = updatedX;
    this.y = updatedY;
  }

  updateData(playerData) {
    this.data.set('health', playerData.health || this.data.get('health'));
    this.data.set('maxHealth', playerData.max_health || this.data.get('maxHealth'));
    this.healthBar.updateHealth(playerData.health, playerData.max_health);
    this.data.set('exp', playerData.exp || this.data.get('exp'));
    this.data.set('speed', playerData.speed || this.data.get('speed'));
    this.data.set('level', playerData.level || this.data.get('level'));
    this.updatePosition(playerData);
  }
}