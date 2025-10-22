enum GameState { menu, playing, gameComplete, gameOver }

class GameStateManager {
  static int _playerLives = 3;

  static void resetLives() {
    _playerLives = 3;
  }

  static void loseLife() {
    if (_playerLives > 0) {
      _playerLives--;
    }
  }

  static bool isGameOver() {
    return _playerLives <= 0;
  }

  static int get currentLives => _playerLives;
}
