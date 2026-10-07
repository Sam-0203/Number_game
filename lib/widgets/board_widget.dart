import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  static const double _gap = 8;
  static const double _padding = 8;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardWidth = constraints.maxWidth - (_padding * 2);
          final cellSize =
              (boardWidth - _gap * (GameState.gridSize - 1)) /
              GameState.gridSize;

          return Container(
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4E69),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                _EmptyGridBackground(cellSize: cellSize, gap: _gap),
                for (final tile in gameState.tiles)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 130),
                    curve: Curves.easeInOut,
                    left: tile.col * (cellSize + _gap),
                    top: tile.row * (cellSize + _gap),
                    width: cellSize,
                    height: cellSize,
                    child: TileWidget(tile: tile),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyGridBackground extends StatelessWidget {
  final double cellSize;
  final double gap;

  const _EmptyGridBackground({required this.cellSize, required this.gap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(GameState.gridSize, (r) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: r == GameState.gridSize - 1 ? 0 : gap,
          ),
          child: Row(
            children: List.generate(GameState.gridSize, (c) {
              return Padding(
                padding: EdgeInsets.only(
                  right: c == GameState.gridSize - 1 ? 0 : gap,
                ),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
