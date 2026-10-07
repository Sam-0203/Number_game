import 'package:flutter/material.dart';
import '../models/tile_entity.dart';

class TileWidget extends StatelessWidget {
  final TileEntity tile;

  const TileWidget({super.key, required this.tile});

  static const Map<int, Color> _colors = {
    2: Color(0xFFFFE29A),
    4: Color(0xFFFFC978),
    8: Color(0xFFFF9F45),
    16: Color(0xFFFF7043),
    32: Color(0xFFFF5252),
    64: Color(0xFFE64980),
    128: Color(0xFFCC5DE8),
    256: Color(0xFF9775FA),
    512: Color(0xFF5C7CFA),
    1024: Color(0xFF339AF0),
    2048: Color(0xFF22B8CF),
  };

  Color _backgroundColor(int value) {
    return _colors[value] ?? const Color(0xFF20C997);
  }

  Color _textColor(int value) {
    return value <= 4 ? const Color(0xFF7A5230) : Colors.white;
  }

  double _fontSize(int value) {
    if (value < 100) return 30;
    if (value < 1000) return 26;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${tile.id}-${tile.value}-${tile.isNew}-${tile.isMerged}'),
      tween: Tween(begin: (tile.isNew || tile.isMerged) ? 0.6 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor(tile.value),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _backgroundColor(tile.value).withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${tile.value}',
          style: TextStyle(
            fontSize: _fontSize(tile.value),
            fontWeight: FontWeight.w800,
            color: _textColor(tile.value),
          ),
        ),
      ),
    );
  }
}
