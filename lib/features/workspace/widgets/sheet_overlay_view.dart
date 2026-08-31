import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/checkerboard_painter.dart';
import '../../../shared/widgets/checkerboard_background.dart';
import '../../settings/settings_provider.dart';
import '../../settings/settings_screen.dart';
import '../workspace_provider.dart';
import 'detection_overlay_painter.dart';

/// Pane showing the original sprite sheet with detection bounding-box overlays.
/// Supports pan + zoom via InteractiveViewer.
class SheetOverlayView extends StatefulWidget {
  const SheetOverlayView({super.key});

  @override
  State<SheetOverlayView> createState() => _SheetOverlayViewState();
}

class _SheetOverlayViewState extends State<SheetOverlayView> {
  final TransformationController _transformCtrl = TransformationController();

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        final bytes = provider.result?.processedSheetBytes;
        if (bytes == null) {
          return _importPrompt(context);
        }

        return Stack(
          children: [
            // Background: always the checkerboard — fills the entire pane.
            CheckerboardBackground(
              cellSize: 10,
              child: const SizedBox.expand(),
            ),

            // Interactive sheet image with bounding-box overlays.
            InteractiveViewer(
              transformationController: _transformCtrl,
              minScale: 0.1,
              maxScale: 10.0,
              child: LayoutBuilder(builder: (ctx, constraints) {
                return Center(
                  child: _SheetWithOverlay(
                    sheetBytes: bytes,
                    originalBytes: provider.originalImageBytes,
                    provider: provider,
                    constraints: constraints,
                  ),
                );
              }),
            ),

            // Detection failure banner — shown on top when the engine
            // could not segment the sheet into separate elements.
            if (provider.result?.detectionFailure == true)
              _DetectionFailureBanner(provider: provider),

            // Reset zoom button
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'resetZoom',
                tooltip: 'Reset zoom',
                backgroundColor: AppTheme.surfaceCard,
                onPressed: () =>
                    _transformCtrl.value = Matrix4.identity(),
                child: const Icon(Icons.center_focus_strong_outlined,
                    color: AppTheme.onSurfaceMid),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _importPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 64, color: AppTheme.onSurfaceDim),
          const SizedBox(height: 16),
          Text('No sheet loaded',
              style: AppTheme.bodyMedium
                  .copyWith(color: AppTheme.onSurfaceMid)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sheet image with per-image checkerboard base
// ──────────────────────────────────────────────────────────────

class _SheetWithOverlay extends StatelessWidget {
  final List<int> sheetBytes;
  final Uint8List? originalBytes;
  final WorkspaceProvider provider;
  final BoxConstraints constraints;

  const _SheetWithOverlay({
    required this.sheetBytes,
    required this.originalBytes,
    required this.provider,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, _) {
      final result = provider.result!;
      final imgW = result.originalWidth.toDouble();
      final imgH = result.originalHeight.toDouble();

      // Scale to fit the view while maintaining aspect ratio
      final maxW = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : 800.0;
      final maxH = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : 600.0;

      final scaleX = maxW / imgW;
      final scaleY = maxH / imgH;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final dispW = imgW * scale;
      final dispH = imgH * scale;

      return SizedBox(
        width: dispW,
        height: dispH,
        child: Stack(
          children: [
            // Layer 0: Checkerboard pattern — always the base layer for
            // this image frame. This ensures transparent pixels in the
            // processed sheet show the checkerboard, not the scaffold
            // background color (which is black in dark mode).
            Positioned.fill(
              child: CustomPaint(
                painter: const CheckerboardPainter(cellSize: 10),
              ),
            ),

            // Layer 1: Sheet image composited on top of checkerboard.
            Positioned.fill(
              child: Image.memory(
                sheetBytes as dynamic,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                      '[SheetOverlayView] Image.memory decode error: $error\n$stackTrace');
                  // Fallback: try showing the original bytes
                  if (originalBytes != null) {
                    return Image.memory(
                      originalBytes!,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      errorBuilder: (_, e2, st2) {
                        debugPrint(
                            '[SheetOverlayView] Fallback image also failed: $e2\n$st2');
                        return const ColoredBox(color: Colors.transparent);
                      },
                    );
                  }
                  return const ColoredBox(color: Colors.transparent);
                },
              ),
            ),

            // Layer 2: Bounding-box overlays
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) =>
                    _handleTap(details.localPosition, scale, provider),
                child: CustomPaint(
                  painter: DetectionOverlayPainter(
                    elements: provider.elements,
                    selectedIndex: provider.selectedElementIndex,
                    scaleX: scale,
                    scaleY: scale,
                    offsetX: 0,
                    offsetY: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _handleTap(
      Offset localPos, double scale, WorkspaceProvider provider) {
    // Find which element was tapped (last one wins = topmost visually)
    final imgX = localPos.dx / scale;
    final imgY = localPos.dy / scale;
    int? hit;
    for (var i = provider.elements.length - 1; i >= 0; i--) {
      final el = provider.elements[i];
      if (imgX >= el.x &&
          imgX <= el.x + el.width &&
          imgY >= el.y &&
          imgY <= el.y + el.height) {
        hit = i;
        break;
      }
    }
    if (hit != null) {
      provider.selectElement(hit);
    } else {
      provider.clearSelection();
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Detection failure banner
// ──────────────────────────────────────────────────────────────

/// A banner shown at the top of the sheet preview when the engine
/// could not detect separate elements. Provides localized messaging
/// and quick links to Settings and retry.
class _DetectionFailureBanner extends StatelessWidget {
  final WorkspaceProvider provider;

  const _DetectionFailureBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.12),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _titleText(context),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _bodyText(context),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.onSurfaceMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.tune_outlined, size: 16),
                    label: Text(_openSettingsText(context)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentPrimary,
                      textStyle: AppTheme.bodySmall,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_outlined, size: 16),
                    label: Text(_retryText(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryButton,
                      foregroundColor: AppTheme.buttonText,
                      textStyle: AppTheme.bodySmall,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      final settings = context.read<SettingsProvider>();
                      provider.reprocess(settings.processingOptions);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Access localized strings via generated AppLocalizations.
  // Falls back to hardcoded English if the delegate is not yet ready.
  String _titleText(BuildContext context) {
    return AppLocalizations.of(context).detectionFailureTitle;
  }

  String _bodyText(BuildContext context) {
    return AppLocalizations.of(context).detectionFailureBody;
  }

  String _openSettingsText(BuildContext context) {
    return AppLocalizations.of(context).openSettings;
  }

  String _retryText(BuildContext context) {
    return AppLocalizations.of(context).retryDetection;
  }
}
