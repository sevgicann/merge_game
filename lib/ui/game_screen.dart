import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    state = engine.newGame();
  }

  void move(Direction dir) {
    if (state.gameOver) return;

    setState(() {
      state = engine.step(state, dir);
    });
  }

  void restartGame() {
    setState(() {
      state = engine.newGame();
    });
  }

  void handleSwipe(DragEndDetails details) {

    if (state.gameOver) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    if (dx.abs() > dy.abs()) {

      if (dx > 0) {
        move(Direction.right);
      } else {
        move(Direction.left);
      }

    } else {

      if (dy > 0) {
        move(Direction.down);
      } else {
        move(Direction.up);
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfffaf8ef),

      body: SafeArea(
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
              onPanEnd: handleSwipe,
              child: Stack(
                children: [

                  BoardWidget(board: state.board),

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