// configurações principais do jogo
import 'package:flame/game.dart';

class GameConfig {
  // mostrar ou não controles da telatouch
  static const bool showControls = true;
  // ativar ou não sons
  static const bool playSounds = true;
  // volume padrão dos sons
  static const double soundVolume = 1.0;

  // lista de fases disponíveis
  static const List<String> levelNames = ['Level-01', 'Level-02', 'Level-03'];
  // tamanho da câmera do jogo
  static const double cameraWidth = 768;
  static const double cameraHeight = 432;

  // resolução do jogo no formato 16:9
  static Vector2 gameSize = Vector2(768, 432);
}
