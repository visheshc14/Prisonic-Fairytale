import HealthBar from '../users/health_bar';
import { sprites } from '../sprites';

export default class Enemy extends Phaser.GameObjects.Container {
  constructor(scene, enemyData) {
    const updatedX = enemyData.x * 32;
    const updatedY = enemyData.y * 32;
    super(scene, updatedX, updatedY);

    const spriteName = enemyData.sprite || 'snake';
    const frameHeight = sprites[spriteName].frameHeight;
    this.scene = scene;
    this.sprite = scene.add.sprite(0, 0, spriteName);
    this.sprite.setOrigin(0.14, 0.5);
    this.sprite.setScale(64 / frameHeight);
    this.sprite.play(`${spriteName}_walk_up`);
    this.spriteX = updatedX;
    this.spriteY = updatedY;


    this.setDataEnabled();
    this.setData({
      id: enemyData.id,
      health: enemyData.health || 100,
      maxHealth: enemyData.max_health || 100,
      exp: enemyData.exp || 0,
      isMoving: false,
      spriteName: spriteName,
      defaultAnimation: 'idle',
      currentAnimation: 'idle',
      speed: Phaser.Math.GetSpeed(200, 3),
      level: enemyData.level || 0,
      name: enemyData.name || enemyData.id.split('-').pop(),
      playerType: enemyData.type || ""
    });

    this.healthBar = new HealthBar(scene, enemyData.health, enemyData.max_health);
    this.add([this.sprite, this.healthBar]);
    // this.add([this.sprite, this.healthBar]);
    this.scene.add.container(0, 0, this).setExclusive(true);
  }

  play(animationName) {
    if (this.data.get('currentAnimation') == animationName) {
      return;
    }
    this.data.set('currentAnimation', animationName);
    try {
      this.sprite.play(`${this.data.get('spriteName')}_${animationName}`);
    } catch (e) {
      console.error(`Animation: ${this.data.get('spriteName')}_${animationName}`, e);
    }
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

  updateData(enemyData) {
    this.data.set('health', enemyData.health || this.data.get('health'));
    this.data.set('maxHealth', enemyData.max_health || this.data.get('maxHealth'));
    this.healthBar.updateHealth(enemyData.health, enemyData.max_health);
    this.data.set('level', enemyData.level || this.data.get('level'));
    if (enemyData.sprite != this.data.get('spriteName')) {
      this.data.set('spriteName', enemyData.sprite);
    }
    this.updatePosition(enemyData);
  }
}