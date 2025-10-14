import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/screen_manager.dart';
import 'package:pixel_adventure/core/components/button_component.dart';

class GameCompleteScreen extends GameScreen {
  late SpriteComponent congratulations;
  late SpriteComponent trophy;
  late ButtonComponent menuButton;
  final List<Component> _screenComponents = [];

  @override
  Future<void> onLoad() async {
    _createCongratulations();
    _createTrophy();
    _createMenuButton();

    return super.onLoad();
  }

  @override
  void onEnter() {
    // Só adiciona os componentes se eles não estiverem já no parent
    if (!_screenComponents.any((c) => c.isMounted)) {
      addAll([congratulations, trophy, menuButton]);
      _screenComponents.addAll([congratulations, trophy, menuButton]);
    }
  }

  @override
  void onExit() {
    // Remove apenas os componentes que realmente pertencem a esta screen
    final componentsToRemove = _screenComponents
        .where((c) => c.isMounted)
        .toList();
    if (componentsToRemove.isNotEmpty) {
      removeAll(componentsToRemove);
    }
    _screenComponents.clear();
  }

  void _createCongratulations() {
    congratulations = SpriteComponent(
      sprite: Sprite(game.images.fromCache('HUD/Congratulations.png')),
      position: Vector2(game.size.x / 2, game.size.y / 3),
      size: Vector2(300, 300),
      anchor: Anchor.center,
    );
  }

  void _createTrophy() {
    trophy = SpriteComponent(
      sprite: Sprite(game.images.fromCache('HUD/Trophy.png')),
      position: Vector2(game.size.x / 2, game.size.y / 2),
      size: Vector2(100, 100),
      anchor: Anchor.center,
    );
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
  }
}
