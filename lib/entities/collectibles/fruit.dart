import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';
import 'package:pixel_adventure/entities/player/player.dart';

class Fruit extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {
  final String fruit;
  Fruit({this.fruit = 'apple', super.position, super.size});

  static const double stepTime = 0.05;
  final CustomHitbox hitBox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    priority = GameLayers.world;

    add(
      RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      if (game.playSounds) {
        FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );

      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
