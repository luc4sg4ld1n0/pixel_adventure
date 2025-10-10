import 'package:flame/components.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';

abstract class GameComponent extends Component
    with HasGameReference<PixelAdventure> {
  GameComponent();
}
