import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tile_entity.dart';

enum SwipeDirection { up, down, left, right }

class GameState extends ChangeNotifier {
  static const int gridSize = 4;
  static const String _bestScoreKey = 'best_score_2048';

  List<TileEntity> tiles = [];
  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;
  bool hasWon = false;
  bool _continueAfterWin = false;
  int _nextId = 0;

  final Random _random = Random();

  GameState() {
    _loadBestScore();
    startNewGame();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    notifyListeners();
  }

  Future<void> _saveBestScoreIfNeeded() async {
    if (score > bestScore) {
      bestScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestScoreKey, bestScore);
    }
  }

  void startNewGame() {
    tiles = [];
    score = 0;
    isGameOver = false;
    hasWon = false;
    _continueAfterWin = false;
    _nextId = 0;
    _spawnRandomTile();
    _spawnRandomTile();
    notifyListeners();
  }

  void continueAfterWin() {
    _continueAfterWin = true;
    hasWon = false;
    notifyListeners();
  }

  TileEntity? _tileAt(int row, int col) {
    for (final t in tiles) {
      if (t.row == row && t.col == col) return t;
    }
    return null;
  }

  void _spawnRandomTile() {
    final empty = <Point<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_tileAt(r, c) == null) empty.add(Point(r, c));
      }
    }
    if (empty.isEmpty) return;
    final cell = empty[_random.nextInt(empty.length)];
    tiles.add(TileEntity(
      id: _nextId++,
      value: _random.nextDouble() < 0.9 ? 2 : 4,
      row: cell.x,
      col: cell.y,
      isNew: true,
    ));
  }

  void _clearTransientFlags() {
    for (final t in tiles) {
      t.isNew = false;
      t.isMerged = false;
    }
  }

  Point<int> _slotToPosition(SwipeDirection dir, int lineIndex, int slot) {
    switch (dir) {
      case SwipeDirection.left:
        return Point(lineIndex, slot);
      case SwipeDirection.right:
        return Point(lineIndex, gridSize - 1 - slot);
      case SwipeDirection.up:
        return Point(slot, lineIndex);
      case SwipeDirection.down:
        return Point(gridSize - 1 - slot, lineIndex);
    }
  }

  List<TileEntity> _getLine(SwipeDirection dir, int lineIndex) {
    switch (dir) {
      case SwipeDirection.left:
        return tiles.where((t) => t.row == lineIndex).toList()
          ..sort((a, b) => a.col.compareTo(b.col));
      case SwipeDirection.right:
        return tiles.where((t) => t.row == lineIndex).toList()
          ..sort((a, b) => b.col.compareTo(a.col));
      case SwipeDirection.up:
        return tiles.where((t) => t.col == lineIndex).toList()
          ..sort((a, b) => a.row.compareTo(b.row));
      case SwipeDirection.down:
        return tiles.where((t) => t.col == lineIndex).toList()
          ..sort((a, b) => b.row.compareTo(a.row));
    }
  }

  void swipe(SwipeDirection direction) {
    if (isGameOver) return;
    _clearTransientFlags();

    bool moved = false;
    int scoreGained = 0;
    final removedIds = <int>[];

    for (int lineIndex = 0; lineIndex < gridSize; lineIndex++) {
      final line = _getLine(direction, lineIndex);
      int slot = 0;
      TileEntity? lastPlaced;

      for (final current in line) {
        if (lastPlaced != null && lastPlaced.value == current.value) {
          lastPlaced.value *= 2;
          lastPlaced.isMerged = true;
          scoreGained += lastPlaced.value;
          removedIds.add(current.id);
          moved = true;
          lastPlaced = null; // each tile can only merge once per move
          continue;
        }
        final pos = _slotToPosition(direction, lineIndex, slot);
        if (current.row != pos.x || current.col != pos.y) moved = true;
        current.row = pos.x;
        current.col = pos.y;
        lastPlaced = current;
        slot++;
      }
    }

    if (moved) {
      tiles.removeWhere((t) => removedIds.contains(t.id));
      score += scoreGained;
      _spawnRandomTile();
      _checkWin();
      _checkGameOver();
      _saveBestScoreIfNeeded();
    }

    notifyListeners();
  }

  void _checkWin() {
    if (_continueAfterWin) return;
    for (final t in tiles) {
      if (t.value == 2048) {
        hasWon = true;
        return;
      }
    }
  }

  void _checkGameOver() {
    if (tiles.length < gridSize * gridSize) return;
    for (final t in tiles) {
      final right = _tileAt(t.row, t.col + 1);
      if (right != null && right.value == t.value) return;
      final down = _tileAt(t.row + 1, t.col);
      if (down != null && down.value == t.value) return;
    }
    isGameOver = true;
  }
}
