import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/game_state.dart';
import 'package:pixel_adventure/entities/player/player.dart';
import 'package:pixel_adventure/entities/collectibles/checkpoint.dart';
import 'package:pixel_adventure/screens/menu_screen.dart';
import 'package:pixel_adventure/screens/game_complete_screen.dart';
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
  GameState _currentState = GameState.menu;

  late MenuScreen menuScreen;
  late GameCompleteScreen gameCompleteScreen;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    // Inicializa as telas (mas não as ativa ainda)
    menuScreen = MenuScreen();
    gameCompleteScreen = GameCompleteScreen();

    // Adiciona as telas ao jogo (mas inativas)
    await add(menuScreen);
    await add(gameCompleteScreen);

    // Começa com o menu ativo
    _setState(GameState.menu);

    return super.onLoad();
  }

  void _setState(GameState newState) {
    // Desativa a tela atual
    switch (_currentState) {
      case GameState.menu:
        menuScreen.isActive = false;
        break;
      case GameState.playing:
        _cleanCurrentLevel();
        break;
      case GameState.gameComplete:
        gameCompleteScreen.isActive = false;
        break;
    }

    // Ativa a nova tela
    _currentState = newState;

    switch (newState) {
      case GameState.menu:
        menuScreen.isActive = true;
        break;
      case GameState.playing:
        _loadLevel();
        break;
      case GameState.gameComplete:
        gameCompleteScreen.isActive = true;
        break;
    }
  }

  void startGame() {
    currentLevelIndex = 0;
    _setState(GameState.playing);
  }

  void goToMenu() {
    _setState(GameState.menu);
  }

  void completeGame() {
    _setState(GameState.gameComplete);
  }

  @override
  void update(double dt) {
    if (_currentState == GameState.playing && showControls) {
      joystickController.updateJoystick();
    }
    super.update(dt);
  }

  void loadNextLevel() {
    if (currentLevelIndex < GameConfig.levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      completeGame();
    }
  }

  void _loadLevel() {
    _cleanCurrentLevel();

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
    cam.priority = GameLayers.world;

    addAll([cam, world]);

    if (showControls) {
      joystickController = JoystickController();
      add(joystickController);
    }
  }

  void _cleanCurrentLevel() {
    final componentsToRemove = <Component>[];

    for (final component in children) {
      if (component is CameraComponent ||
          component is Level ||
          component is Player ||
          component is JoystickController ||
          component is JoystickComponent ||
          component is JumpButton ||
          component is Checkpoint) {
        componentsToRemove.add(component);
      }
    }

    if (componentsToRemove.isNotEmpty) {
      removeAll(componentsToRemove);
    }

    player = Player();
  }
}
