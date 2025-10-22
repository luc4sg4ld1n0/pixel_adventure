import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class FruitCounter extends Component with HasGameReference<PixelAdventure> {
  late TextComponent _fruitEmoji;
  late TextComponent _xSymbol;
  late TextComponent _counterText;
  int _fruitCount = 0;

  @override
  FutureOr<void> onLoad() {
    _createFruitEmoji();
    _createXSymbol();
    _createCounterText();
    _updateCounterText();

    return super.onLoad();
  }

  void _createFruitEmoji() {
    _fruitEmoji = TextComponent(
      text: '🍓',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFFFFFFFF),
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Color(0xFF000000),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      position: Vector2(
        GameConfig.cameraWidth / 2 - 45, // Emoji à esquerda
        GameConfig.cameraHeight - 35, // Centralizado verticalmente
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_fruitEmoji);
  }

  void _createXSymbol() {
    _xSymbol = TextComponent(
      text: 'x',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Color(0xFF000000),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      position: Vector2(
        GameConfig.cameraWidth / 2 - 15, // Entre emoji e número
        GameConfig.cameraHeight - 35, // Centralizado verticalmente
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_xSymbol);
  }

  void _createCounterText() {
    _counterText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
          shadows: [
            Shadow(
              blurRadius: 3,
              color: Color(0xFF000000),
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      position: Vector2(
        GameConfig.cameraWidth / 2 + 15, // Número à direita
        GameConfig.cameraHeight - 35, // Centralizado verticalmente
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_counterText);
  }

  void _updateCounterText() {
    _counterText.text = '$_fruitCount';
  }

  void collectFruit() {
    _fruitCount++;
    _updateCounterText();
    _animateCollection();
  }

  void _animateCollection() {
    // Efeito visual quando coleta fruta
    final originalScale = _fruitEmoji.scale.clone();

    // Animação de escala no emoji
    _fruitEmoji.scale = originalScale * 1.2;

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_fruitEmoji.isMounted) {
        _fruitEmoji.scale = originalScale;
      }
    });
  }

  void resetCounter() {
    _fruitCount = 0;
    _updateCounterText();
  }

  int get fruitCount => _fruitCount;
}
