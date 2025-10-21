import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with TapCallbacks, HasGameReference<PixelAdventure> {
  final Vector2 gameAreaOffset;
  bool _isPressed = false;
  bool get isPressed => _isPressed;

  JumpButton({required this.gameAreaOffset});

  static const double margin = 32;
  static const double buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));

    // Posiciona dentro da área do jogo (canto inferior direito)
    position = Vector2(
      gameAreaOffset.x + GameConfig.gameSize.x - margin - buttonSize,
      gameAreaOffset.y + GameConfig.gameSize.y - margin - buttonSize,
    );

    size = Vector2(buttonSize, buttonSize);
    priority = GameLayers.controls;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    super.onTapCancel(event);
  }
}
