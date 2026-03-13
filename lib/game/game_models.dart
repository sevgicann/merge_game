import 'dart:math';

enum Direction { left, right, up, down }

class GameState {
  final int size;
  final List<List<int>> board; // 0 = empty
  final int score;
  final bool gameOver;

  const GameState({
    required this.size,
    required this.board,
    required this.score,
    required this.gameOver,
  });

  factory GameState.empty({required int size}) {
    return GameState(
      size: size,
      board: List.generate(size, (_) => List.generate(size, (_) => 0)),
      score: 0,
      gameOver: false,
    );
  }

  GameState copyWith({
    List<List<int>>? board,
    int? score,
    bool? gameOver,
  }) {
    return GameState(
      size: size,
      board: board ?? this.board,
      score: score ?? this.score,
      gameOver: gameOver ?? this.gameOver,
    );
  }
}

class MoveResult {
  final List<List<int>> board;
  final bool moved;
  final int gained;

  const MoveResult({
    required this.board,
    required this.moved,
    required this.gained,
  });
}

class SpawnResult {
  final List<List<int>> board;
  final bool spawned;
  final Point<int>? at;
  final int? value;

  const SpawnResult({
    required this.board,
    required this.spawned,
    this.at,
    this.value,
  });
}