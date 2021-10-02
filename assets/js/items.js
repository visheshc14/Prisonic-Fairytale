import { sprites } from './sprites';

export default class Item extends Phaser.GameObjects.Container {
  constructor(scene, itemData) {
    const updated_x = itemData.x * 32;
    const updated_y = itemData.y * 32;
    super(scene, updated_x, updated_y);
    this.scene = scene;

    const spriteName = itemData.sprite || 'psycho_medic';
    const frameHeight = sprites[spriteName].frameHeight;

    this.scene = scene;
    this.sprite = scene.add.sprite(0, 0, spriteName);
    this.sprite.setOrigin(-0.01, 0.01);
    this.sprite.setScale(32 / frameHeight);

    this.setDataEnabled();
    this.setData({
      id: itemData.id,
      spriteName: itemData.name,
      name: itemData.name || 'psycho_medic',
      description: itemData.description,
    });

    this.add([this.sprite]);

    // scene.add.container(200, 300).setExclusive(true);
    //  You can either do this:
    this.scene.add.container(0, 0, this).setExclusive(true);
  }

}