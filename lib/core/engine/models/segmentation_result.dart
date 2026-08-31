import 'dart:typed_data';
import 'detected_element.dart';

/// The complete output of processing a single sprite sheet.
class SegmentationResult {
  /// PNG-encoded version of the full sheet with background removed (alpha mask applied).
  /// On detection failure, this contains the original sheet bytes (so the preview
  /// panel can still display the image correctly).
  final Uint8List processedSheetBytes;

  /// Original sheet dimensions (in pixels).
  final int originalWidth;
  final int originalHeight;

  /// All detected elements, in order of detection (top-to-bottom, left-to-right).
  final List<DetectedElement> elements;

  /// True when background removal could not produce meaningful separation —
  /// e.g. >90% of the canvas remained as foreground after the flood-fill,
  /// or CCL returned a single blob covering the full canvas.
  ///
  /// When this is true, [elements] is empty and [processedSheetBytes] contains
  /// the original (unmodified) sheet so it can still be previewed.
  final bool detectionFailure;

  /// Human-readable diagnostic log lines produced by the engine during this run.
  /// Each entry is a single line. Returned from the isolate so the main thread
  /// can forward them to [LogService].
  final List<String> diagnosticLog;

  const SegmentationResult({
    required this.processedSheetBytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.elements,
    this.detectionFailure = false,
    this.diagnosticLog = const [],
  });

  int get elementCount => elements.length;

  /// Returns a copy with updated fields.
  SegmentationResult copyWith({
    Uint8List? processedSheetBytes,
    int? originalWidth,
    int? originalHeight,
    List<DetectedElement>? elements,
    bool? detectionFailure,
    List<String>? diagnosticLog,
  }) =>
      SegmentationResult(
        processedSheetBytes: processedSheetBytes ?? this.processedSheetBytes,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
        elements: elements ?? this.elements,
        detectionFailure: detectionFailure ?? this.detectionFailure,
        diagnosticLog: diagnosticLog ?? this.diagnosticLog,
      );

  /// Returns a new result with [elements] replaced with renumbered IDs.
  SegmentationResult withRenumberedElements(List<DetectedElement> newElements) {
    final renumbered = newElements.asMap().entries.map((e) {
      final idx = e.key;
      final el = e.value;
      final newId = 'element_${(idx + 1).toString().padLeft(3, '0')}';
      return el.copyWith(id: newId, index: idx);
    }).toList();
    return copyWith(elements: renumbered);
  }
}
