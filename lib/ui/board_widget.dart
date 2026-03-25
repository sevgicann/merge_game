import 'dart:math';
import 'package:flutter/material.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final List<List<int>> board;

  // 🔥 YENİ: merge olan tile’lar
  final List<Point<int>> mergedTiles;

  const BoardWidget({
    super.key,
    required this.board,
    this.mergedTiles = const [],
  });

  @override
  Widget build(BuildContext context) {
    const double boardSize = 350;
    const double gap = 10;
    const int grid = 4;

    final tileSize = (boardSize - (gap * (grid + 1))) / grid;

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: const Color(0xffbbada0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [

          // background grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grid * grid,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: grid,
              mainAxisSpacing: gap,
              crossAxisSpacing: gap,
            ),
            itemBuilder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xffcdc1b4),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),

          // tiles
          ..._buildTiles(tileSize, gap)

        ],
      ),
    );
  }

  List<Widget> _buildTiles(double tileSize, double gap) {
    final tiles = <Widget>[];

    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        final value = board[r][c];
        if (value == 0) continue;

        // 🔥 merge kontrolü
        final isMerged = mergedTiles.any((p) => p.x == r && p.y == c);

        tiles.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            left: c * (tileSize + gap),
            top: r * (tileSize + gap),

            child: SizedBox(
              width: tileSize,
              height: tileSize,

              // 🔥 POP EFFECT (merge animasyonu)
              child: AnimatedScale(
                scale: isMerged ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,

                child: AnimatedTile(value: value),
              ),
            ),
          ),
        );
      }
    }

    return tiles;
  }
}