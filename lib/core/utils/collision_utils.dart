import 'package:pixel_adventure/entities/player/player.dart';
import 'package:pixel_adventure/world/environment/collision_block.dart';

bool checkCollision(Player player, CollisionBlock block) {
  // elementos básicos para o cálculo de colisão

  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;
  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // cálculo de colisão otimizado levando em consideração o tamanho do sprite do jogador
  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;

  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}
