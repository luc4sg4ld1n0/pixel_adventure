import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class JoystickController extends Component
    with HasGameReference<PixelAdventure> {
  late JoystickComponent joystick;

  @override
  FutureOr<void> onLoad() {
    _addJoystick();
    return super.onLoad();
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    game.add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        game.player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        game.player.horizontalMovement = 1;
        break;
      default:
        game.player.horizontalMovement = 0;
        break;
    }
  }

  @override
  void onRemove() {
    joystick.removeFromParent();
    super.onRemove();
  }
}
