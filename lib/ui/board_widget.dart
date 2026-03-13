import 'package:flutter/material.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {

  final List<List<int>> board;

  const BoardWidget({
    super.key,
    required this.board,
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

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 16,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
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

        tiles.add(

          AnimatedPositioned(
            duration: const Duration(milliseconds: 120),
            left: c * (tileSize + gap),
            top: r * (tileSize + gap),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
              child: AnimatedTile(value: value),
            ),
          ),

        );

      }

    }

    return tiles;
  }

}