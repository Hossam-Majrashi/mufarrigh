import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Paints a checkerboard pattern to represent transparency.
class CheckerboardPainter extends CustomPainter {
  final Color lightColor;
  final Color darkColor;
  final double cellSize;

  const CheckerboardPainter({
    this.lightColor = AppTheme.checkerLight,
    this.darkColor = AppTheme.checkerDark,
    this.cellSize = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = lightColor;
    final dark = Paint()..color = darkColor;

    final cols = (size.width / cellSize).ceil();
    final rows = (size.height / cellSize).ceil();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final isLight = (r + c) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
          isLight ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CheckerboardPainter oldDelegate) =>
      oldDelegate.lightColor != lightColor ||
      oldDelegate.darkColor != darkColor ||
      oldDelegate.cellSize != cellSize;
}
