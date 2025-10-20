import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  BackgroundTile({this.color = 'Gray', super.position});

  static const double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    priority = GameLayers.background;
    size = Vector2.all(64);
    return super.onLoad();
  }
}
