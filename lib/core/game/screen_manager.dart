import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

abstract class GameScreen extends Component
    with HasGameReference<PixelAdventure> {
  bool _isActive = false;

  GameScreen();

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }

  /// Chamado quando a screen é ativada
  void onEnter();

  /// Chamado quando a screen é desativada
  void onExit();

  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      if (_isActive) {
        onEnter();
      } else {
        onExit();
      }
    }
  }
}
