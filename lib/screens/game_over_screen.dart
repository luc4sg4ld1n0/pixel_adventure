import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/screen_manager.dart';
import 'package:pixel_adventure/core/components/button_component.dart';

class GameOverScreen extends GameScreen {
  late SpriteComponent gameOver;
  late ButtonComponent menuButton;
  final List<Component> _screenComponents = [];

  @override
  Future<void> onLoad() async {
    _createGameOver();
    _createMenuButton();

    return super.onLoad();
  }

  @override
  void onEnter() {
    if (!_screenComponents.any((c) => c.isMounted)) {
      addAll([gameOver, menuButton]);
      _screenComponents.addAll([gameOver, menuButton]);
    }
  }

  @override
  void onExit() {
    final componentsToRemove = _screenComponents
        .where((c) => c.isMounted)
        .toList();
    if (componentsToRemove.isNotEmpty) {
      removeAll(componentsToRemove);
    }
    _screenComponents.clear();
  }

  void _createGameOver() {
    gameOver = SpriteComponent(
      sprite: Sprite(game.images.fromCache('HUD/GameOver.png')),
      position: Vector2(game.size.x / 2, game.size.y / 3),
      size: Vector2(300, 300),
      anchor: Anchor.center,
    );
    priority = GameLayers.backgroundElements;
  }

  void _createMenuButton() {
    menuButton = ButtonComponent(
      position: Vector2(game.size.x / 2, game.size.y * 2 / 2.5),
      size: Vector2(200, 80),
      text: 'VOLTAR AO MENU',
      onPressed: () {
        game.goToMenu();
      },
    );
    priority = GameLayers.ui;
  }
}
