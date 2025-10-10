import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

abstract class Enemy extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Enemy({super.position, super.size});

  void collidedWithPlayer();
}
