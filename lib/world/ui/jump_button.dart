import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with TapCallbacks, HasGameReference<PixelAdventure> {
  JumpButton();

  static const double margin = 32;
  static const double buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - buttonSize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
