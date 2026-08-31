import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/engine/models/detected_element.dart';
import '../../../core/theme/app_theme.dart';

/// CustomPainter that draws bounding-box overlays on the sprite sheet.
class DetectionOverlayPainter extends CustomPainter {
  final List<DetectedElement> elements;
  final int? selectedIndex;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;

  const DetectionOverlayPainter({
    required this.elements,
    required this.selectedIndex,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = AppTheme.accentSecondary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final selectedPaint = Paint()
      ..color = AppTheme.accentPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = AppTheme.accentSecondary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final selectedFillPaint = Paint()
      ..color = AppTheme.accentPrimary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < elements.length; i++) {
      final el = elements[i];
      final isSelected = i == selectedIndex;

      final rect = Rect.fromLTWH(
        offsetX + el.x * scaleX,
        offsetY + el.y * scaleY,
        el.width * scaleX,
        el.height * scaleY,
      );

      canvas.drawRect(rect, isSelected ? selectedFillPaint : fillPaint);
      canvas.drawRect(
          rect, isSelected ? selectedPaint : normalPaint);

      // Draw index label
      if (rect.width > 20 && rect.height > 12) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: TextStyle(
              color: isSelected ? AppTheme.accentPrimary : AppTheme.accentSecondary,
              fontSize: math.min(11.0, rect.width / 3),
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, rect.topLeft + const Offset(3, 2));
      }
    }
  }

  @override
  bool shouldRepaint(DetectionOverlayPainter old) =>
      old.elements != elements ||
      old.selectedIndex != selectedIndex ||
      old.scaleX != scaleX ||
      old.scaleY != scaleY;
}
