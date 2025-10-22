import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:pixel_adventure/core/game/game_config.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/game_state.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

class LifeCounter extends Component with HasGameReference<PixelAdventure> {
  late TextComponent _lifeEmoji;
  late TextComponent _xSymbol;
  late TextComponent _counterText;
  Vector2 _originalScale = Vector2(1, 1);

  @override
  FutureOr<void> onLoad() {
    _createLifeEmoji();
    _createXSymbol();
    _createCounterText();
    updateLives();

    return super.onLoad();
  }

  void _createLifeEmoji() {
    _lifeEmoji = TextComponent(
      text: '❤️',
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
        GameConfig.cameraWidth / 2 + 45,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    _originalScale = _lifeEmoji.scale.clone();
    add(_lifeEmoji);
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
        GameConfig.cameraWidth / 2 + 75,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_xSymbol);
  }

  void _createCounterText() {
    _counterText = TextComponent(
      text: '3',
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
        GameConfig.cameraWidth / 2 + 105,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_counterText);
  }

  void updateLives() {
    _counterText.text = '${GameStateManager.currentLives}';
    _animateUpdate();
  }

  void _animateUpdate() {
    // Reseta para escala original antes de animar
    _lifeEmoji.scale = _originalScale.clone();

    // Animação mais suave sem acumular escala
    final targetScale = _originalScale * 0.7;
    _lifeEmoji.scale = targetScale;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_lifeEmoji.isMounted) {
        _lifeEmoji.scale = _originalScale.clone();
      }
    });
  }

  // Método para garantir que a escala seja resetada quando necessário
  void resetScale() {
    if (_lifeEmoji.isMounted) {
      _lifeEmoji.scale = _originalScale.clone();
    }
  }
}
