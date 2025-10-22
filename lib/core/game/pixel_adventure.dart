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
import 'package:pixel_adventure/world/ui/fruit_counter.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  CameraComponent? cam;
  Player player = Player();
  JoystickController? joystickController;
  late FruitCounter fruitCounter;

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

    // Inicializa as telas
    menuScreen = MenuScreen();
    gameCompleteScreen = GameCompleteScreen();

    // Adiciona as telas ao jogo
    await add(menuScreen);
    await add(gameCompleteScreen);

    // Inicializa o contador de frutas (mas não adiciona ainda)
    fruitCounter = FruitCounter();

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
        // RESETA o contador quando sai da tela de jogo completo
        _resetFruitCounter();
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
      joystickController?.updateJoystick();
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
    cam!.viewfinder.anchor = Anchor.topLeft;
    cam!.priority = GameLayers.world;

    addAll([cam!, world]);

    // Adiciona o contador de frutas ao viewport (SEMPRE)
    if (!fruitCounter.isMounted) {
      cam!.viewport.add(fruitCounter);
    } else {
      // Se já está montado, garante que está no viewport correto
      if (fruitCounter.parent != cam!.viewport) {
        fruitCounter.removeFromParent();
        cam!.viewport.add(fruitCounter);
      }
    }

    if (showControls) {
      joystickController = JoystickController();
      add(joystickController!);
    }

    // NÃO reseta o contador aqui - mantém entre fases
    // fruitCounter.resetCounter();
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

    // Remove APENAS controles do viewport, NÃO o FruitCounter
    if (cam != null && cam!.viewport.children.isNotEmpty) {
      final viewportComponents = cam!.viewport.children
          .where(
            (component) =>
                component is JoystickComponent || component is JumpButton,
          )
          .toList();

      if (viewportComponents.isNotEmpty) {
        cam!.viewport.removeAll(viewportComponents);
      }
    }

    if (componentsToRemove.isNotEmpty) {
      removeAll(componentsToRemove);
    }

    // Reseta o player
    player = Player();
    joystickController = null;
  }

  // Método para resetar o contador quando o jogo é completado
  void _resetFruitCounter() {
    fruitCounter.resetCounter();
  }
}
