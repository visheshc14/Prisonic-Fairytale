import health_pots from './health_pots';
import player from './player';
import snake from './snake';
import wizard from './wizard';
import psycho_medic from './psycho_medic';
import skeleton from './skeleton';

// const spriteList = [base.name, health_pots.small.name, dark.name];
const spriteList = [health_pots.small.name, player.name, snake.name, wizard.name, psycho_medic.name, skeleton.name];
export const sprites = {};
// sprites[brawler.name] = brawler;
// sprites[base.name] = base;
sprites[health_pots.small.name] = health_pots.small;
sprites[player.name] = player;
sprites[snake.name] = snake;
sprites[wizard.name] = wizard;
sprites[psycho_medic.name] = psycho_medic;
sprites[skeleton.name] = skeleton;

function addAnimation(spriteData) {
  // Loop over every animation for a sprite
  spriteData.animationList.map(animationName => {
    const animationData = spriteData.animations[animationName];

    // Generate animation frames
    frames = this.anims.generateFrameNumbers(
      spriteData.name, { frames: animationData.frames });

    this.anims.create({
      key: animationName,
      frames: frames,
      frameRate: animationData.frameRate,
      repeat: animationData.repeat,
      repeatDelay: animationData.repeatDelay
    })
  })
}

function addAnimations(spriteList, spritesData) {
  // Loop over all sprites
  spriteList.map(spriteName => {
    addAnimation.call(this, spritesData[spriteName]);
  });
}

export default {
  spriteList: spriteList,
  data: sprites,
  addAnimation: addAnimation,
  addAnimations: addAnimations
};