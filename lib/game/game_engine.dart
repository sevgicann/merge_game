import 'dart:math';
import 'package:merge_game/game/game_models.dart';

class GameEngine {
  final Random _rng;

  GameEngine({Random? rng}) : _rng = rng ?? Random();

  GameState newGame({int size = 4}) {
    var state = GameState.empty(size: size);
    state = _spawn(state).state;
    state = _spawn(state).state;

    return state.copyWith(gameOver: !_hasMoves(state.board));
  }

  GameState step(GameState state, Direction dir) {
    return stepWithResult(state, dir).state;
  }

  EngineStepResult stepWithResult(GameState state, Direction dir) {
    if (state.gameOver) {
      return EngineStepResult(
        state: state,
        mergedTiles: const [],
        spawnedTile: null,
      );
    }

    final move = _move(state.board, dir);

    if (!move.moved) {
      final unchanged = state.copyWith(
        gameOver: !_hasMoves(state.board),
      );

      return EngineStepResult(
        state: unchanged,
        mergedTiles: const [],
        spawnedTile: null,
      );
    }

    var next = state.copyWith(
      board: move.board,
      score: state.score + move.gained,
    );

    final spawned = _spawn(next);
    next = spawned.state;

    next = next.copyWith(
      gameOver: !_hasMoves(next.board),
    );

    return EngineStepResult(
      state: next,
      mergedTiles: move.mergedTiles,
      spawnedTile: spawned.result.spawned ? spawned.result.at : null,
    );
  }

  MoveResult testMove(List<List<int>> board, Direction dir) {
    return _move(board, dir);
  }

  MoveResult _move(List<List<int>> board, Direction dir) {
    final size = board.length;
    final newBoard =
        List.generate(size, (_) => List.generate(size, (_) => 0));

    bool anyChanged = false;
    int gainedTotal = 0;
    final mergedTiles = <Point<int>>[];

    List<int> getLine(int i) {
      switch (dir) {
        case Direction.left:
          return List<int>.from(board[i]);
        case Direction.right:
          return List<int>.from(board[i].reversed);
        case Direction.up:
          return List<int>.generate(size, (r) => board[r][i]);
        case Direction.down:
          return List<int>.generate(size, (r) => board[size - 1 - r][i]);
      }
    }

    void setLine(int i, List<int> line) {
      switch (dir) {
        case Direction.left:
          newBoard[i] = line;
          break;
        case Direction.right:
          newBoard[i] = line.reversed.toList();
          break;
        case Direction.up:
          for (int r = 0; r < size; r++) {
            newBoard[r][i] = line[r];
          }
          break;
        case Direction.down:
          for (int r = 0; r < size; r++) {
            newBoard[size - 1 - r][i] = line[r];
          }
          break;
      }
    }

    for (int i = 0; i < size; i++) {
      final line = getLine(i);
      final collapsed = _collapseLeft(line, size);

      if (collapsed.changed) anyChanged = true;
      gainedTotal += collapsed.gained;
      setLine(i, collapsed.line);

      for (final idx in collapsed.mergedIndexes) {
        switch (dir) {
          case Direction.left:
            mergedTiles.add(Point(i, idx));
            break;
          case Direction.right:
            mergedTiles.add(Point(i, size - 1 - idx));
            break;
          case Direction.up:
            mergedTiles.add(Point(idx, i));
            break;
          case Direction.down:
            mergedTiles.add(Point(size - 1 - idx, i));
            break;
        }
      }
    }

    return MoveResult(
      board: newBoard,
      moved: anyChanged,
      gained: gainedTotal,
      mergedTiles: mergedTiles,
    );
  }

  _Collapse _collapseLeft(List<int> line, int size) {
    final original = List<int>.from(line);
    final nums = line.where((v) => v != 0).toList();

    final out = <int>[];
    final mergedIndexes = <int>[];

    int gained = 0;
    int i = 0;

    while (i < nums.length) {
      if (i + 1 < nums.length && nums[i] == nums[i + 1]) {
        final v = nums[i] * 2;
        out.add(v);
        mergedIndexes.add(out.length - 1);
        gained += v;
        i += 2;
      } else {
        out.add(nums[i]);
        i += 1;
      }
    }

    while (out.length < size) {
      out.add(0);
    }

    final changed = !_listEq(original, out);
    return _Collapse(out, changed, gained, mergedIndexes);
  }

  bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  _SpawnWrap _spawn(GameState state) {
    final b = _deepCopy(state.board);
    final empties = <Point<int>>[];
    final size = b.length;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (b[r][c] == 0) {
          empties.add(Point(r, c));
        }
      }
    }

    if (empties.isEmpty) {
      return _SpawnWrap(
        state: state,
        result: const SpawnResult(
          board: [],
          spawned: false,
        ),
      );
    }

    final p = empties[_rng.nextInt(empties.length)];
    final v = _rng.nextDouble() < 0.9 ? 2 : 4;
    b[p.x][p.y] = v;

    final next = state.copyWith(board: b);

    return _SpawnWrap(
      state: next,
      result: SpawnResult(
        board: b,
        spawned: true,
        at: p,
        value: v,
      ),
    );
  }

  List<List<int>> _deepCopy(List<List<int>> b) {
    return List.generate(
      b.length,
      (r) => List<int>.from(b[r]),
    );
  }

  bool _hasMoves(List<List<int>> b) {
    final size = b.length;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (b[r][c] == 0) return true;
      }
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = b[r][c];

        if (r + 1 < size && b[r + 1][c] == v) return true;
        if (c + 1 < size && b[r][c + 1] == v) return true;
      }
    }

    return false;
  }
}

class EngineStepResult {
  final GameState state;
  final List<Point<int>> mergedTiles;
  final Point<int>? spawnedTile;

  const EngineStepResult({
    required this.state,
    required this.mergedTiles,
    required this.spawnedTile,
  });
}

class _Collapse {
  final List<int> line;
  final bool changed;
  final int gained;
  final List<int> mergedIndexes;

  _Collapse(this.line, this.changed, this.gained, this.mergedIndexes);
}

class _SpawnWrap {
  final GameState state;
  final SpawnResult result;

  _SpawnWrap({
    required this.state,
    required this.result,
  });
}