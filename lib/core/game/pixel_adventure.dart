import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/entities/player/player.dart';
import 'package:pixel_adventure/world/level/level.dart';
import 'package:pixel_adventure/world/ui/jump_button.dart';
import 'package:pixel_adventure/world/ui/joystick_controller.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player();
  late JoystickController joystickController;

  bool showControls = GameConfig.showControls;
  bool playSounds = GameConfig.playSounds;
  double soundVolume = GameConfig.soundVolume;

  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();

    if (showControls) {
      joystickController = JoystickController();
      add(joystickController);
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      joystickController.updateJoystick();
    }
    super.update(dt);
  }

  void loadNextLevel() {
    // carregar a próxima fase
    if (currentLevelIndex < GameConfig.levelNames.length - 1) {
      currentLevelIndex++;
    } else {
      currentLevelIndex = 0;
    }
    _loadLevel();
  }

  void _loadLevel() {
    // carregar uma nova fase
    Future.delayed(const Duration(seconds: 1), () {
      _cleanCurrentLevel();

      player = Player();

      final world = Level(
        player: player,
        levelName: GameConfig.levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: GameConfig.cameraWidth,
        height: GameConfig.cameraHeight,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }

  void _cleanCurrentLevel() {
    // limpa a fase para preparar para a próxima fase
    children.whereType<CameraComponent>().forEach(remove);
    children.whereType<Level>().forEach(remove);
    children.whereType<Player>().forEach(remove);
    children.whereType<JoystickController>().forEach(remove);
    children.whereType<JoystickComponent>().forEach(remove);
  }
}
