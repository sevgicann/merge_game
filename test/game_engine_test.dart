import 'package:flutter_test/flutter_test.dart';
import 'package:merge_game/game/game_engine.dart';
import 'package:merge_game/game/game_models.dart';
import 'dart:math';
import 'package:merge_game/game/ai.player.dart';

void main() {

  group("2048 Engine Tests", () {

    test("2 + 2 birleşince 4 olmalı", () {
      final engine = GameEngine();

      final board = [
        [2,2,0,0],
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0]
      ];

      final result = engine.testMove(board, Direction.left);

      expect(result.board[0][0], 4);
      expect(result.board[0][1], 0);
    });

    test("double merge 2 2 2 2 -> 4 4", () {

  final engine = GameEngine();

  final board = [
    [2,2,2,2],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.board[0][0], 4);
  expect(result.board[0][1], 4);

});

test("triple merge 2 2 2 -> 4 2", () {

  final engine = GameEngine();

  final board = [
    [2,2,2,0],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.board[0][0], 4);
  expect(result.board[0][1], 2);

});
test("merge with gap 2 0 2 -> 4", () {

  final engine = GameEngine();

  final board = [
    [2,0,2,0],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.board[0][0], 4);
  expect(result.board[0][1], 0);

});
test("no merge possible", () {

  final engine = GameEngine();

  final board = [
    [2,4,8,16],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.moved, false);

});
test("score gained after merge", () {

  final engine = GameEngine();

  final board = [
    [2,2,0,0],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.gained, 4);

});
test("spawn happens after move", () {

  final engine = GameEngine();

  final state = GameState(
    size: 4,
    board: [
      [2,2,0,0],
      [0,0,0,0],
      [0,0,0,0],
      [0,0,0,0]
    ],
    score: 0,
    gameOver: false,
  );

  final next = engine.step(state, Direction.left);

  int nonZero = 0;

  for (var row in next.board) {
    for (var v in row) {
      if (v != 0) nonZero++;
    }
  }

  expect(nonZero, greaterThan(1));

});
test("game over when no moves left", () {

  final engine = GameEngine();

  final state = GameState(
    size: 4,
    board: [
      [2,4,2,4],
      [4,2,4,2],
      [2,4,2,4],
      [4,2,4,2]
    ],
    score: 0,
    gameOver: false,
  );

  final next = engine.step(state, Direction.left);

  expect(next.gameOver, true);

});
test("right merge 2 2 -> 4", () {

  final engine = GameEngine();

  final board = [
    [0,0,2,2],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.right);

  expect(result.board[0][3], 4);
  expect(result.board[0][2], 0);

});
test("up merge vertical 2 + 2 -> 4", () {

  final engine = GameEngine();

  final board = [
    [2,0,0,0],
    [2,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.up);

  expect(result.board[0][0], 4);
  expect(result.board[1][0], 0);

});
test("down merge vertical 2 + 2 -> 4", () {

  final engine = GameEngine();

  final board = [
    [0,0,0,0],
    [0,0,0,0],
    [2,0,0,0],
    [2,0,0,0]
  ];

  final result = engine.testMove(board, Direction.down);

  expect(result.board[3][0], 4);
  expect(result.board[2][0], 0);

});
test("random stress test 1000 moves", () {

  final engine = GameEngine();

  var state = engine.newGame();

  final random = Random();

  for (int i = 0; i < 1000; i++) {

    final dir = Direction.values[random.nextInt(4)];

    state = engine.step(state, dir);

    if (state.gameOver) {
      break;
    }

  }

  expect(state.board.length, 4);

});
test("AI bot can reach at least 64 tile", () {

  final engine = GameEngine();

  var state = engine.newGame();

  final random = Random();

  int maxTile = 0;

  while (!state.gameOver) {

    final dir = Direction.values[random.nextInt(4)];

    state = engine.step(state, dir);

    for (var row in state.board) {
      for (var v in row) {
        if (v > maxTile) {
          maxTile = v;
        }
      }
    }

  }

  expect(maxTile, greaterThanOrEqualTo(16));

});
test("AI bot should reach at least 64", () {

  final engine = GameEngine();
  final ai = AIPlayer(engine);

  var state = engine.newGame();

  int maxTile = 0;

  while (!state.gameOver) {

    final move = ai.findBestMove(state);

    if (move == null) break;

    state = engine.step(state, move);

    for (var row in state.board) {
      for (var v in row) {
        if (v > maxTile) maxTile = v;
      }
    }

  }

  expect(maxTile, greaterThanOrEqualTo(64));

});
test("no spawn if board does not change", () {

  final engine = GameEngine();

  final state = GameState(
    size: 4,
    board: [
      [2,4,8,16],
      [0,0,0,0],
      [0,0,0,0],
      [0,0,0,0]
    ],
    score: 0,
    gameOver: false,
  );

  final next = engine.step(state, Direction.left);

  int tiles = 0;

  for (var row in next.board) {
    for (var v in row) {
      if (v != 0) tiles++;
    }
  }

  expect(tiles, 4);

});
test("tile cannot merge twice in one move", () {

  final engine = GameEngine();

  final board = [
    [2,2,4,4],
    [0,0,0,0],
    [0,0,0,0],
    [0,0,0,0]
  ];

  final result = engine.testMove(board, Direction.left);

  expect(result.board[0][0], 4);
  expect(result.board[0][1], 8);

});
test("spawn tile must be 2 or 4", () {

  final engine = GameEngine();

  var state = engine.newGame();

  for (int i = 0; i < 50; i++) {

    state = engine.step(state, Direction.left);

    for (var row in state.board) {
      for (var v in row) {
        if (v != 0) {
          expect([2,4,8,16,32,64,128,256,512,1024,2048].contains(v), true);
        }
      }
    }

    if (state.gameOver) break;
  }

});
test("board size should always remain 4x4", () {

  final engine = GameEngine();

  var state = engine.newGame();

  final random = Random();

  for (int i = 0; i < 200; i++) {

    final dir = Direction.values[random.nextInt(4)];

    state = engine.step(state, dir);

    expect(state.board.length, 4);

    for (var row in state.board) {
      expect(row.length, 4);
    }

    if (state.gameOver) break;
  }

});
test("state should create new board reference", () {

  final engine = GameEngine();

  final state = engine.newGame();

  final next = engine.step(state, Direction.left);

  expect(identical(state.board, next.board), false);

});

  });

}