import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/screen_manager.dart';
import 'package:pixel_adventure/core/components/button_component.dart';

class MenuScreen extends GameScreen {
  late SpriteComponent title;
  late ButtonComponent startButton;
  final List<Component> _screenComponents = [];

  @override
  Future<void> onLoad() async {
    _createTitle();
    _createStartButton();

    return super.onLoad();
  }

  @override
  void onEnter() {
    // Só adiciona os componentes se eles não estiverem já no parent
    if (!_screenComponents.any((c) => c.isMounted)) {
      addAll([title, startButton]);
      _screenComponents.addAll([title, startButton]);
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

  void _createTitle() {
    title = SpriteComponent(
      sprite: Sprite(game.images.fromCache('HUD/Title.png')),
      position: Vector2(game.size.x / 2, game.size.y / 3),
      size: Vector2(400, 400),
      anchor: Anchor.center,
    );
  }

  void _createStartButton() {
    startButton = ButtonComponent(
      position: Vector2(game.size.x / 2, game.size.y / 1.3),
      size: Vector2(200, 80),
      text: 'INICIAR JOGO',
      onPressed: () {
        game.startGame();
      },
    );
  }
}
