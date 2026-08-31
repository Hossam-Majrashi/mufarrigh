import 'package:flutter/material.dart';
import '../../core/utils/checkerboard_painter.dart';

/// A widget that paints a checkerboard pattern to represent transparency.
/// Wrap any transparent-background image with this.
class CheckerboardBackground extends StatelessWidget {
  final Widget child;
  final double cellSize;

  const CheckerboardBackground({
    super.key,
    required this.child,
    this.cellSize = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CheckerboardPainter(cellSize: cellSize),
      child: child,
    );
  }
}
