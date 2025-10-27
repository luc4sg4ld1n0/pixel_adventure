import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/core/game/game_state.dart';
import 'package:pixel_adventure/core/game/pixel_adventure.dart';
import 'package:pixel_adventure/core/utils/constants.dart';
import 'package:pixel_adventure/core/utils/collision_utils.dart';
import 'package:pixel_adventure/entities/collectibles/fruit.dart';
import 'package:pixel_adventure/entities/enemies/chicken.dart';
import 'package:pixel_adventure/world/environment/collision_block.dart';
import 'package:pixel_adventure/world/environment/saw.dart';
import 'main_player_state.dart';
import 'player_animations.dart';

class Player extends SpriteAnimationGroupComponent<MainPlayerState>
    with KeyboardHandler, CollisionCallbacks, HasGameReference<PixelAdventure> {
  final String character;
  Player({super.position, this.character = 'Ninja Frog'});

  late final PlayerAnimations _animations;
  final Vector2 startingPosition = Vector2.zero();
  final Vector2 velocity = Vector2.zero();

  double _keyboardHorizontalMovement = 0;
  double _touchHorizontalMovement = 0;
  bool _keyboardJump = false;
  bool _touchJump = false;

  double horizontalMovement = 0;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  List<CollisionBlock> collisionBlocks = [];
  final CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _animations = PlayerAnimations(game, character);
    _loadAllAnimations();

    startingPosition.setFrom(position);

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _updateKeyboardInput(keysPressed);
    return true;
  }

  void _updateKeyboardInput(Set<LogicalKeyboardKey> keysPressed) {
    _keyboardHorizontalMovement = 0;
    _keyboardJump = false;

    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    _keyboardHorizontalMovement += isLeftKeyPressed ? -1 : 0;
    _keyboardHorizontalMovement += isRightKeyPressed ? 1 : 0;

    _keyboardJump =
        keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
  }

  void updateTouchInput(double horizontalMovement, bool jump) {
    _touchHorizontalMovement = horizontalMovement;
    _touchJump = jump;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Chicken) other.collidedWithPlayer();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    animations = {
      MainPlayerState.idle: _animations.createIdleAnimation(),
      MainPlayerState.running: _animations.createRunningAnimation(),
      MainPlayerState.jumping: _animations.createJumpingAnimation(),
      MainPlayerState.falling: _animations.createFallingAnimation(),
      MainPlayerState.hit: _animations.createHitAnimation(),
      MainPlayerState.appearing: _animations.createAppearingAnimation(),
      MainPlayerState.disappearing: _animations.createDisappearingAnimation(),
    };

    current = MainPlayerState.idle;
  }

  void _updatePlayerState() {
    MainPlayerState playerState = MainPlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) playerState = MainPlayerState.running;
    if (velocity.y > 0) playerState = MainPlayerState.falling;
    if (velocity.y < 0) playerState = MainPlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (_keyboardHorizontalMovement != 0) {
      horizontalMovement = _keyboardHorizontalMovement;
    } else {
      horizontalMovement = _touchHorizontalMovement;
    }

    hasJumped = _keyboardJump || _touchJump;

    if (hasJumped && isOnGround) _playerJump(dt);

    if (velocity.y > GameConstants.gravity) isOnGround = false;

    velocity.x = horizontalMovement * GameConstants.playerMoveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play('jump.wav', volume: game.soundVolume);
    }
    velocity.y = -GameConstants.jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform && checkCollision(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offsetX - hitbox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          break;
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += GameConstants.gravity;
    velocity.y = velocity.y.clamp(
      -GameConstants.jumpForce,
      GameConstants.terminalVelocity,
    );
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block)) {
        if (block.isPlatform) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        } else {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (gotHit || reachedCheckpoint) return;

    if (game.playSounds) {
      FlameAudio.play('hit.wav', volume: game.soundVolume);
    }

    gotHit = true;
    current = MainPlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    game.playerDied();

    if (!GameStateManager.isGameOver()) {
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = MainPlayerState.appearing;

      await animationTicker?.completed;
      animationTicker?.reset();

      velocity.setZero();
      position.setFrom(startingPosition);

      _updatePlayerState();

      await Future.delayed(const Duration(milliseconds: 400));
      gotHit = false;
    }
  }

  Future<void> startCheckpointSequence() async {
    if (reachedCheckpoint) return;

    reachedCheckpoint = true;

    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }

    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    // Animação de desaparecimento
    current = MainPlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();
  }

  void collidedWithEnemy() {
    _respawn();
  }
}

class CustomHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
