import 'package:flutter/foundation.dart';
import 'game_engine.dart';
import 'game_models.dart';

/// GameController manages the game state and notifies listeners on changes.
class GameController extends ChangeNotifier {
  final GameEngine engine;
  late GameState state;



  GameController({GameEngine? engine, int size = 4})
      : engine = engine ?? GameEngine() {
    state = this.engine.newGame(size: size);
  }

  int get size => state.size;
/// Resets the game to a new state, optionally with a different board size.
  void reset({int? size}) {
    state = engine.newGame(size: size ?? state.size);
    notifyListeners();
  }
/// Attempts to move in the given direction. If the state changes, notifies listeners.
  void move(Direction dir) {
    final next = engine.step(state, dir);
    if (!identical(next, state)) {
      state = next;
      notifyListeners();
    }
  }
}

