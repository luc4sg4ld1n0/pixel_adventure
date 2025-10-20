// import 'dart:async';
// import 'package:flame/components.dart';
// import 'package:flutter/painting.dart';
// import 'package:pixel_adventure/core/game/pixel_adventure.dart';

// class JoystickController extends Component
//     with HasGameReference<PixelAdventure> {
//   late JoystickComponent joystick;

//   @override
//   FutureOr<void> onLoad() {
//     _addJoystick();
//     return super.onLoad();
//   }

//   void _addJoystick() {
//     joystick = JoystickComponent(
//       priority: 10,
//       knob: SpriteComponent(
//         sprite: Sprite(game.images.fromCache('HUD/Knob.png')),
//       ),
//       background: SpriteComponent(
//         sprite: Sprite(game.images.fromCache('HUD/Joystick.png')),
//       ),
//       margin: const EdgeInsets.only(left: 32, bottom: 32),
//     );

//     game.add(joystick);
//   }

//   void updateJoystick() {
//     switch (joystick.direction) {
//       case JoystickDirection.left:
//       case JoystickDirection.upLeft:
//       case JoystickDirection.downLeft:
//         game.player.horizontalMovement = -1;
//         break;
//       case JoystickDirection.right:
//       case JoystickDirection.upRight:
//       case JoystickDirection.downRight:
//         game.player.horizontalMovement = 1;
//         break;
//       default:
//         game.player.horizontalMovement = 0;
//         break;
//     }
//   }

//   @override
//   void onRemove() {
//     joystick.removeFromParent();
//     super.onRemove();
//   }
// }

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';
import 'package:pixel_adventure/world/ui/jump_button.dart';

class JoystickController extends Component
    with HasGameReference<PixelAdventure> {
  late JoystickComponent joystick;
  late JumpButton jumpButton;

  @override
  FutureOr<void> onLoad() {
    _addJoystick();
    _addJumpButton();
    return super.onLoad();
  }

  void _addJoystick() {
    final gameAreaOffset = _getGameAreaOffset();

    joystick = JoystickComponent(
      priority: GameLayers.controls,
      knob: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Joystick.png')),
      ),
      margin: EdgeInsets.only(
        left: gameAreaOffset.x + 32, // Dentro da área do jogo
        bottom: gameAreaOffset.y + 32, // Dentro da área do jogo
      ),
    );

    game.add(joystick);
  }

  void _addJumpButton() {
    final gameAreaOffset = _getGameAreaOffset();

    jumpButton = JumpButton(gameAreaOffset: gameAreaOffset);
    game.add(jumpButton);
  }

  Vector2 _getGameAreaOffset() {
    // Calcula o offset da área do jogo (para centralizar na tela)
    final offsetX = (game.size.x - GameConfig.gameSize.x) / 2;
    final offsetY = (game.size.y - GameConfig.gameSize.y) / 2;
    return Vector2(offsetX, offsetY);
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
    jumpButton.removeFromParent();
    super.onRemove();
  }
}
