import Enemy from './enemy';

export default class Enemies {
  constructor(enemiesData) {
    this.data = {};
    this.ids = [];
    this.unrenderedEnemies = enemiesData || [];
    this.destroyList = [];
    this.moves = { list: [], dirty: false };
    // this.addEnemies(playersData);
  }

  newPlayer(enemyData) {
    this.unrenderedEnemies.push(enemyData);
  }

  renderEnemy(scene) {
    const length = this.unrenderedEnemies.length;
    if (length > 0) {
      let newEnemy;
      for (let i = 0; i < length; i++) {
        newEnemy = new Enemy(scene, this.unrenderedEnemies[i]);
        this.addEnemy(newEnemy);
      }
      this.unrenderedEnemies = [];
    }
  }

  removeEnemy(id) {
    // Failing to remove players at the moment
    const enemy = this.data[id];
    if (enemy != undefined) {
      this.ids.filter(enemyId => enemyId != id)
      enemy.removeAll();
      enemy.destroy(true);
      delete this.data[id];
    } else {
      console.error(`ID is missing ${id}`)
    }
  }

  removeEnemies() {
    this.destroyList.forEach(enemyId => this.removePlayer(enemyId));
    this.destroyList = [];
  }

  addEnemy(enemy) {
    const enemyId = enemy.data.get('id')
    this.data[enemyId] = enemy;
    this.ids.push(enemyId);
  }

  updateEnemy(enemyData) {
    const enemy = this.data[enemyData.id];
    if (enemy != undefined) {
      enemy.updateData(enemyData);
    }
  }
}