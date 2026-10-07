import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              _Header(gameState: gameState),
              const SizedBox(height: 20),
              _Instructions(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      final v = details.primaryVelocity ?? 0;
                      if (v.abs() < 100) return;
                      if (v > 0) {
                        gameState.swipe(SwipeDirection.right);
                      } else {
                        gameState.swipe(SwipeDirection.left);
                      }
                    },
                    onVerticalDragEnd: (details) {
                      final v = details.primaryVelocity ?? 0;
                      if (v.abs() < 100) return;
                      if (v > 0) {
                        gameState.swipe(SwipeDirection.down);
                      } else {
                        gameState.swipe(SwipeDirection.up);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const BoardWidget(),
                        if (gameState.hasWon) _GameOverlay(
                          title: 'You Win!',
                          buttonLabel: 'Keep Going',
                          onPrimary: gameState.continueAfterWin,
                          onNewGame: gameState.startNewGame,
                        ),
                        if (gameState.isGameOver) _GameOverlay(
                          title: 'Game Over',
                          buttonLabel: 'Try Again',
                          onPrimary: gameState.startNewGame,
                          onNewGame: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final GameState gameState;
  const _Header({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '2048',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4A4E69),
          ),
        ),
        Row(
          children: [
            _ScoreBox(label: 'SCORE', value: gameState.score),
            const SizedBox(width: 8),
            _ScoreBox(label: 'BEST', value: gameState.bestScore),
            const SizedBox(width: 8),
            IconButton(
              onPressed: gameState.startNewGame,
              icon: const Icon(Icons.refresh),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE64980),
                foregroundColor: Colors.white,
              ),
              tooltip: 'New Game',
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E69),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC9C9E0),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Swipe to move tiles. Merge matching numbers to reach 2048!',
        style: TextStyle(fontSize: 14, color: Color(0xFF6B6B8D)),
      ),
    );
  }
}

class _GameOverlay extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onNewGame;

  const _GameOverlay({
    required this.title,
    required this.buttonLabel,
    required this.onPrimary,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE64980),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
