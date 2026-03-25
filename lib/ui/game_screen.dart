import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_engine.dart';
import '../game/game_models.dart';
import 'board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameEngine engine = GameEngine();
  late GameState state;

  final FocusNode _focusNode = FocusNode();

  // 🔥 merge edilen tile’ları tutacağız
  List<Point<int>> mergedTiles = [];

  @override
  void initState() {
    super.initState();
    state = engine.newGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // 🔥 ARTIK stepWithResult kullanıyoruz
  void move(Direction dir) {
    if (state.gameOver) return;

    final result = engine.stepWithResult(state, dir);

    setState(() {
      state = result.state;
      mergedTiles = result.mergedTiles;
    });

    // animasyon sonrası temizle
    Future.delayed(const Duration(milliseconds: 140), () {
      setState(() {
        mergedTiles = [];
      });
    });
  }

  void restartGame() {
    setState(() {
      state = engine.newGame();
      mergedTiles = [];
    });
  }

  void handleSwipe(DragEndDetails details) {
    if (state.gameOver) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() > dy.abs()) {
      move(dx > 0 ? Direction.right : Direction.left);
    } else {
      move(dy > 0 ? Direction.down : Direction.up);
    }
  }

  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {

      // Arrow keys
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        move(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        move(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        move(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        move(Direction.right);
      }

      // WASD
      else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        move(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        move(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        move(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        move(Direction.right);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xfffaf8ef),

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 20),

                Text(
                  "Score: ${state.score}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff776e65),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  onPanEnd: handleSwipe,
                  child: Stack(
                    children: [

                      // 🔥 MERGE DATA BURAYA GİDİYOR
                      BoardWidget(
                        board: state.board,
                        mergedTiles: mergedTiles,
                      ),

                      if (state.gameOver) _gameOverOverlay()

                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => move(Direction.up),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => move(Direction.left),
                    ),

                    const SizedBox(width: 40),

                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => move(Direction.right),
                    ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => move(Direction.down),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameOverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xfffaf8ef),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Game Over",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff776e65),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Score: ${state.score}",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: restartGame,
                  child: const Text("Play Again"),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}