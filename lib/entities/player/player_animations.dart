import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class PlayerAnimations {
  final PixelAdventure game;
  final String character;

  PlayerAnimations(this.game, this.character);

  static const double stepTime = 0.05;

  SpriteAnimation createIdleAnimation() {
    return _createAnimation('Idle', 11);
  }

  SpriteAnimation createRunningAnimation() {
    return _createAnimation('Run', 12);
  }

  SpriteAnimation createJumpingAnimation() {
    return _createAnimation('Jump', 1);
  }

  SpriteAnimation createFallingAnimation() {
    return _createAnimation('Fall', 1);
  }

  SpriteAnimation createHitAnimation() {
    return _createAnimation('Hit', 7)..loop = false;
  }

  SpriteAnimation createAppearingAnimation() {
    return _createSpecialAnimation('Appearing', 7);
  }

  SpriteAnimation createDisappearingAnimation() {
    return _createSpecialAnimation('Disappearing', 7);
  }

  SpriteAnimation _createAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _createSpecialAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }
}
