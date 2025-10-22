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
import 'package:pixel_adventure/screens/game_over_screen.dart';
import 'package:pixel_adventure/screens/menu_screen.dart';
import 'package:pixel_adventure/screens/game_complete_screen.dart';
import 'package:pixel_adventure/world/level/level.dart';
import 'package:pixel_adventure/world/ui/jump_button.dart';
import 'package:pixel_adventure/world/ui/joystick_controller.dart';
import 'package:pixel_adventure/world/ui/fruit_counter.dart';
import 'package:pixel_adventure/world/ui/life_counter.dart';

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
  late LifeCounter lifeCounter;

  bool showControls = GameConfig.showControls;
  bool playSounds = GameConfig.playSounds;
  double soundVolume = GameConfig.soundVolume;

  int currentLevelIndex = 0;
  GameState _currentState = GameState.menu;
  bool _isProcessingDeath = false;

  late MenuScreen menuScreen;
  late GameCompleteScreen gameCompleteScreen;
  late GameOverScreen gameOverScreen;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    // Inicializa as telas
    menuScreen = MenuScreen();
    gameCompleteScreen = GameCompleteScreen();
    gameOverScreen = GameOverScreen();

    // Adiciona as telas ao jogo
    await add(menuScreen);
    await add(gameCompleteScreen);
    await add(gameOverScreen);

    // Inicializa os contadores (mas não adiciona ainda)
    fruitCounter = FruitCounter();
    lifeCounter = LifeCounter();

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
        _resetFruitCounter(); // Reseta frutas ao sair da tela de completo
        break;
      case GameState.gameOver:
        gameOverScreen.isActive = false;
        _resetFruitCounter(); // Reseta frutas ao sair da tela de game over
        break;
    }

    // Ativa a nova tela
    _currentState = newState;

    switch (newState) {
      case GameState.menu:
        menuScreen.isActive = true;
        _resetFruitCounter(); // reseta o contador de frutas ao voltar ao menu
        break;
      case GameState.playing:
        _loadLevel();
        break;
      case GameState.gameComplete:
        gameCompleteScreen.isActive = true;
        break;
      case GameState.gameOver:
        gameOverScreen.isActive = true;
        break;
    }
  }

  void startGame() {
    currentLevelIndex = 0;
    GameStateManager.resetLives();
    _isProcessingDeath = false;
    _setState(GameState.playing);
  }

  void goToMenu() {
    _isProcessingDeath = false;
    _setState(GameState.menu);
  }

  void completeGame() {
    _setState(GameState.gameComplete);
  }

  void goToGameOver() {
    _isProcessingDeath = false;
    _setState(GameState.gameOver);
  }

  void restartGame() {
    GameStateManager.resetLives();
    _isProcessingDeath = false;
    _setState(GameState.playing);
  }

  void playerDied() {
    if (_isProcessingDeath) return;

    _isProcessingDeath = true;

    GameStateManager.loseLife();
    lifeCounter.updateLives();

    if (GameStateManager.isGameOver()) {
      // Vai direto para game over sem respawn
      Future.delayed(const Duration(milliseconds: 500), () {
        goToGameOver();
      });
    } else {
      // Continua no jogo, o player já está fazendo a animação de respawn
      _isProcessingDeath = false;
    }
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
      GameStateManager.resetLives();
      _isProcessingDeath = false;
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

    // Adiciona os contadores ao viewport
    if (!fruitCounter.isMounted) {
      cam!.viewport.add(fruitCounter);
    } else {
      if (fruitCounter.parent != cam!.viewport) {
        fruitCounter.removeFromParent();
        cam!.viewport.add(fruitCounter);
      }
    }

    if (!lifeCounter.isMounted) {
      cam!.viewport.add(lifeCounter);
    } else {
      if (lifeCounter.parent != cam!.viewport) {
        lifeCounter.removeFromParent();
        cam!.viewport.add(lifeCounter);
      }
    }

    lifeCounter.resetScale();

    if (showControls) {
      joystickController = JoystickController();
      add(joystickController!);
    }

    lifeCounter.updateLives();
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

    player = Player();
    joystickController = null;
  }

  void _resetFruitCounter() {
    fruitCounter.resetCounter();
  }
}
