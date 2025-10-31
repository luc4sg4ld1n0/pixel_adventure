enum GameState { menu, playing, gameComplete, gameOver }

class GameStateManager {
  static int _playerLives = 3;
  static String _selectedCharacter = '';

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

  static void setSelectedCharacter(String character) {
    _selectedCharacter = character;
  }

  static String get selectedCharacter => _selectedCharacter;

  static List<String> get availableCharacters => [
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy',
  ];
}
