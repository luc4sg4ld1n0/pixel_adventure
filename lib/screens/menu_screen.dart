import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/screen_manager.dart';
import 'package:pixel_adventure/core/game/game_state.dart';
import 'package:pixel_adventure/core/components/button_component.dart';

class MenuScreen extends GameScreen {
  late SpriteComponent background;
  late SpriteComponent title;
  late ButtonComponent startButton;
  late ButtonComponent leftArrow;
  late ButtonComponent rightArrow;
  late SpriteComponent characterPreview;

  final List<Component> _screenComponents = [];

  int _currentCharacterIndex = 0;
  Vector2 _originalCharacterScale = Vector2(1, 1);

  MenuScreen();

  @override
  Future<void> onLoad() async {
    _createBackground();
    _createTitle();
    _createStartButton();
    _createCharacterSelector();

    return super.onLoad();
  }

  @override
  void onEnter() {
    if (!_screenComponents.any((c) => c.isMounted)) {
      addAll([
        background,
        title,
        startButton,
        leftArrow,
        rightArrow,
        characterPreview,
      ]);
      _screenComponents.addAll([
        background,
        title,
        startButton,
        leftArrow,
        rightArrow,
        characterPreview,
      ]);
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

  void _createBackground() {
    background = SpriteComponent(
      sprite: Sprite(game.images.fromCache('Background/titleBackground.png')),
      size: game.size,
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    );
    priority = GameLayers.background;
  }

  void _createTitle() {
    title = SpriteComponent(
      sprite: Sprite(game.images.fromCache('HUD/Title.png')),
      position: Vector2(game.size.x / 2, game.size.y / 4),
      size: Vector2(300, 300),
      anchor: Anchor.center,
    );
    priority = GameLayers.backgroundElements;
  }

  void _createStartButton() {
    startButton = ButtonComponent(
      position: Vector2(game.size.x / 2, game.size.y / 1.2),
      size: Vector2(180, 70),
      text: 'INICIAR JOGO',
      onPressed: () {
        GameStateManager.setSelectedCharacter(
          GameStateManager.availableCharacters[_currentCharacterIndex],
        );
        game.startGame();
      },
    );
    priority = GameLayers.ui;
  }

  void _createCharacterSelector() {
    final characters = GameStateManager.availableCharacters;

    leftArrow = ButtonComponent(
      position: Vector2(game.size.x / 2 - 100, game.size.y / 1.75),
      size: Vector2(50, 50),
      text: '◀',
      onPressed: _previousCharacter,
      borderRadius: 25,
    );
    leftArrow.priority = GameLayers.ui;

    rightArrow = ButtonComponent(
      position: Vector2(game.size.x / 2 + 100, game.size.y / 1.75),
      size: Vector2(50, 50),
      text: '▶',
      onPressed: _nextCharacter,
      borderRadius: 25,
    );
    rightArrow.priority = GameLayers.ui;

    characterPreview = SpriteComponent(
      sprite: Sprite(
        game.images.fromCache(
          'Main Characters/${characters[_currentCharacterIndex]}/Jump (32x32).png',
        ),
      ),
      position: Vector2(game.size.x / 2, game.size.y / 1.75),
      size: Vector2(60, 60),
      anchor: Anchor.center,
    );
    characterPreview.priority = GameLayers.ui;

    _originalCharacterScale = characterPreview.scale.clone();
  }

  void _nextCharacter() {
    final characters = GameStateManager.availableCharacters;
    _currentCharacterIndex = (_currentCharacterIndex + 1) % characters.length;
    _updateCharacterPreview();
  }

  void _previousCharacter() {
    final characters = GameStateManager.availableCharacters;
    _currentCharacterIndex = (_currentCharacterIndex - 1) % characters.length;
    if (_currentCharacterIndex < 0) {
      _currentCharacterIndex = characters.length - 1;
    }
    _updateCharacterPreview();
  }

  void _updateCharacterPreview() {
    final characters = GameStateManager.availableCharacters;
    final selectedCharacter = characters[_currentCharacterIndex];

    characterPreview.sprite = Sprite(
      game.images.fromCache(
        'Main Characters/$selectedCharacter/Jump (32x32).png',
      ),
    );

    _animateCharacterChange();
  }

  void _animateCharacterChange() {
    characterPreview.scale = _originalCharacterScale.clone();
    characterPreview.scale = _originalCharacterScale * 1.2;

    Future.delayed(const Duration(milliseconds: 150), () {
      if (characterPreview.isMounted) {
        characterPreview.scale = _originalCharacterScale.clone();
      }
    });
  }
}
