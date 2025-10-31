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
  late TextComponent _slashAndTotal;
  int _fruitCount = 0;
  Vector2 _originalScale = Vector2(1, 1);
  Timer? _animationTimer;
  bool _isLoaded = false;

  @override
  FutureOr<void> onLoad() {
    _createFruitEmoji();
    _createXSymbol();
    _createCounterText();
    _createSlashAndTotal();
    _updateCounterText();

    _isLoaded = true;
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
        GameConfig.cameraWidth / 2 - 120,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    _originalScale = _fruitEmoji.scale.clone();
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
        GameConfig.cameraWidth / 2 - 90,
        GameConfig.cameraHeight - 35,
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
        GameConfig.cameraWidth / 2 - 60,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_counterText);
  }

  void _createSlashAndTotal() {
    _slashAndTotal = TextComponent(
      text: '/5',
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
        GameConfig.cameraWidth / 2 - 42,
        GameConfig.cameraHeight - 35,
      ),
      anchor: Anchor.center,
      priority: GameLayers.ui,
    );

    add(_slashAndTotal);
  }

  void _updateCounterText() {
    if (_isLoaded) {
      _counterText.text = '$_fruitCount';

      if (_fruitCount >= 5) {
        _counterText.textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF00FF00),
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
        );

        _slashAndTotal.textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF00FF00),
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
        );

        _xSymbol.textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF00FF00),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Color(0xFF000000),
                offset: Offset(1, 1),
              ),
            ],
          ),
        );
      } else {
        _counterText.textRenderer = TextPaint(
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
        );

        _slashAndTotal.textRenderer = TextPaint(
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
        );

        _xSymbol.textRenderer = TextPaint(
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
        );
      }
    }
  }

  void collectFruit() {
    if (!_isLoaded) return;

    _fruitCount++;
    _updateCounterText();
    _animateCollection();
  }

  void _animateCollection() {
    if (!_isLoaded) return;

    _stopAnimation();

    _fruitEmoji.scale = _originalScale.clone();
    _fruitEmoji.scale = _originalScale * 1.3;

    _animationTimer = Timer(
      0.15,
      onTick: () {
        if (_fruitEmoji.isMounted) {
          _fruitEmoji.scale = _originalScale.clone();
          _animationTimer = null;
        }
      },
    );
  }

  void _stopAnimation() {
    if (_animationTimer != null) {
      _animationTimer = null;
    }
    if (_isLoaded && _fruitEmoji.isMounted) {
      _fruitEmoji.scale = _originalScale.clone();
    }
  }

  @override
  void update(double dt) {
    _animationTimer?.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _stopAnimation();
    super.onRemove();
  }

  void resetCounter() {
    if (!_isLoaded) return;

    _fruitCount = 0;
    _updateCounterText();
    _stopAnimation();
  }

  int get fruitCount => _fruitCount;
}
