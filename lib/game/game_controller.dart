import 'package:flutter/foundation.dart';
import 'game_engine.dart';
import 'game_models.dart';

class GameController extends ChangeNotifier {
  final GameEngine engine;
  late GameState state;

  GameController({GameEngine? engine, int size = 4})
      : engine = engine ?? GameEngine() {
    state = this.engine.newGame(size: size);
  }

  int get size => state.size;

  void reset({int? size}) {
    state = engine.newGame(size: size ?? state.size);
    notifyListeners();
  }

  void move(Direction dir) {
    final next = engine.step(state, dir);
    if (!identical(next, state)) {
      state = next;
      notifyListeners();
    }
  }
}