import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/core/game/game_layers.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';
import 'package:pixel_adventure/entities/player/player.dart';

class Checkpoint extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {
  Checkpoint({super.position, super.size});

  bool isActive = false;
  bool _hasBeenActivated = false;
  bool _isProcessingCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive,
      ),
    );

    priority = GameLayers.world;

    // Inicia com a animação desativada
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Verifica se tem frutas suficientes para ativar o checkpoint
    if (!_hasBeenActivated && game.fruitCounter.fruitCount >= 5) {
      _activateCheckpoint();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) {
      // Se está ativo e não está processando, inicia a sequência do checkpoint
      if (isActive && !_isProcessingCheckpoint) {
        _startCheckpointSequence(other);
      }

      if (!isActive && game.playSounds) {
        FlameAudio.play('hit.wav', volume: game.soundVolume * 0.5);
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {}
    super.onCollisionEnd(other);
  }

  void _activateCheckpoint() {
    if (_hasBeenActivated) return;

    isActive = true;
    _hasBeenActivated = true;

    if (game.playSounds) {
      FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
    }

    // Muda a animação para mostrar que está ativo
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    // Após a animação, mantém a bandeira hasteada
    animationTicker?.completed.then((_) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png',
        ),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
        ),
      );
    });
  }

  void _startCheckpointSequence(Player player) async {
    if (_isProcessingCheckpoint) return;

    _isProcessingCheckpoint = true;

    // Chama o método do player para fazer a animação de desaparecimento
    await player.startCheckpointSequence();

    // REMOVE o player do jogo após a animação
    player.removeFromParent();

    // Delay antes de mudar de fase
    await Future.delayed(const Duration(seconds: 2));

    // Muda para a próxima fase
    game.loadNextLevel();

    _isProcessingCheckpoint = false;
  }
}
