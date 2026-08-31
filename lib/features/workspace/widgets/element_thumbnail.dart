import 'package:flutter/material.dart';
import '../../../core/engine/models/detected_element.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/checkerboard_background.dart';

/// Thumbnail card for a single detected element in the grid.
class ElementThumbnail extends StatelessWidget {
  final DetectedElement element;
  final int index;
  final bool isSelected;
  final bool isChecked; // for export multi-select
  final Color? previewBackgroundColor; // null = transparent
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ElementThumbnail({
    super.key,
    required this.element,
    required this.index,
    required this.isSelected,
    required this.isChecked,
    required this.previewBackgroundColor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentPrimary
                : isChecked
                    ? AppTheme.accentSecondary
                    : AppTheme.divider,
            width: isSelected || isChecked ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _buildPreview(),
            ),

            // Index badge
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfacePanelBg.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.onSurface,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            // Checkbox (export select mode)
            if (isChecked)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.check,
                      color: AppTheme.buttonText, size: 14),
                ),
              ),

            // Bottom label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.surfacePanelBg.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(11)),
                ),
                child: Text(
                  element.displayName,
                  style: AppTheme.bodySmall.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      if (previewBackgroundColor != null) {
        return Container(
          color: previewBackgroundColor,
          width: size.width,
          height: size.height,
          child: _image(size),
        );
      }
      return CheckerboardBackground(
        cellSize: 6,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: _image(size),
        ),
      );
    });
  }

  Widget _image(Size size) {
    return Image.memory(
      element.cropBytes,
      fit: BoxFit.contain,
      width: size.width,
      height: size.height,
      gaplessPlayback: true,
    );
  }
}
