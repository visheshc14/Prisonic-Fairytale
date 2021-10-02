const HUD = new Phaser.Class({

  Extends: Phaser.Scene,

  initialize:

    function HUD() {
      Phaser.Scene.call(this, { key: 'HUD', active: true });

      this.score = 0;
    },

  create: function () {
    //  Our Text object to display the Score
    var info = this.add.text(10, 10, 'FPS: ' + this.sys.game.loop.actualFps.toFixed(2), { font: '16px Courier', fill: '#ffffff' });

    //  Grab a reference to the Game Scene
    var ourGame = this.scene.get('GameScene');

    //  Listen for events from it
    ourGame.events.on('updateHUD', function (user) {
      info.setText([
        `Name: ${user.data.get('name')}`,
        `FPS: ${this.sys.game.loop.actualFps.toFixed(2)}`,
        `Cords: ${user.y / 32}/${user.x / 32}`,
        `Health: ${user.data.get('health')} / ${user.data.get('maxHealth')}`,
        `Exp: ${user.data.get('exp')}`,
        `Level: ${user.data.get('level')}`
      ]);

    }, this);
  }

});

export default HUD;
