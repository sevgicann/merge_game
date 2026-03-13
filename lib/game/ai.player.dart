import 'game_engine.dart';
import 'game_models.dart';

class AIPlayer {

  final GameEngine engine;

  AIPlayer(this.engine);

  Direction? findBestMove(GameState state) {

    Direction? bestMove;
    double bestScore = -999999;

    for (var dir in Direction.values) {

      final result = engine.testMove(state.board, dir);

      if (!result.moved) continue;

      final score = _evaluate(result.board);

      if (score > bestScore) {
        bestScore = score;
        bestMove = dir;
      }

    }

    return bestMove;
  }

  double _evaluate(List<List<int>> board) {

    int empty = 0;
    int maxTile = 0;

    for (var row in board) {
      for (var v in row) {
        if (v == 0) empty++;
        if (v > maxTile) maxTile = v;
      }
    }

    return empty * 10 + maxTile.toDouble();
  }

}