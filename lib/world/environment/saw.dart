import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';
import 'package:pixel_adventure/core/utils/constants.dart';

class Saw extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {
  final bool isVertical;
  final double offNeg;
  final double offPos;

  Saw({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    super.position,
    super.size,
  });

  static const double sawSpeed = 0.03;
  static const double moveSpeed = 50;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = GameLayers.backgroundElements;
    add(CircleHitbox());

    if (isVertical) {
      rangeNeg = position.y - (offNeg * GameConstants.tileSize);
      rangePos = position.y + (offPos * GameConstants.tileSize);
    } else {
      rangeNeg = position.x - (offNeg * GameConstants.tileSize);
      rangePos = position.x + (offPos * GameConstants.tileSize);
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawSpeed,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveSpeed * moveDirection * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveSpeed * moveDirection * dt;
  }
}
