export default class HealthBar extends Phaser.GameObjects.Graphics {

  constructor(scene, health, maxHealth) {
    super(scene);
    this.x = -0.5;
    this.y = -20;
    this.health = health;
    this.maxHealth = maxHealth;
    this.fillWidth = 30;
    this.fillPercent = Math.floor((this.health / this.maxHealth) * this.fillWidth);

    this.draw();
  }

  getFillPercent(health, maxHealth) {
    return Math.floor((health / maxHealth) * this.fillWidth);
  }

  updateHealth(health, maxHealth) {
    // if (health != this.health || maxHealth != this.maxHealth) {
    this.health = health;
    this.maxhealth = maxHealth;
    this.fillPercent = this.getFillPercent(health, maxHealth);
    this.draw();
    // }
  }

  draw() {
    this.clear();

    //  BG
    this.fillStyle(0x000000);
    this.fillRect(this.x, this.y, 34, 16);

    //  Health
    this.fillStyle(0xffffff);
    this.fillRect(this.x + 2, this.y + 2, this.fillWidth, 12);

    if (this.fillPercent < 30) {
      this.fillStyle(0xff0000);
    }
    else {
      this.fillStyle(0x00ff00);
    }

    this.fillRect(this.x + 2, this.y + 2, this.fillPercent, 12);
  }

}