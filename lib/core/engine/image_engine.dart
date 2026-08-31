import 'dart:typed_data';
import 'models/detected_element.dart';
import 'models/export_options.dart';
import 'models/processing_options.dart';
import 'models/segmentation_result.dart';

export 'models/processing_options.dart';
export 'models/detected_element.dart';
export 'models/segmentation_result.dart';
export 'models/export_options.dart';

/// Progress callback signature used by the engine during processing.
typedef ProgressCallback = void Function(String stepName, double progress);

/// Abstract interface for the image segmentation engine.
///
/// The concrete implementation ([DartImageEngine]) uses only the pure-Dart
/// `image` package. Future implementations may use platform channels or FFI
/// bindings to native libraries — but must NEVER vendor OpenCV source.
abstract class ImageEngine {
  /// Process a full sprite sheet image.
  ///
  /// [imageBytes] — raw bytes of the input image (PNG / JPG / WebP).
  /// [options]    — tuning parameters for background removal and segmentation.
  /// [onProgress] — optional callback receiving step name (0..1) progress.
  ///
  /// Returns a [SegmentationResult] containing the background-removed sheet
  /// and all detected element crops.
  ///
  /// Runs in an isolate; the caller's thread is never blocked.
  Future<SegmentationResult> processSheet({
    required Uint8List imageBytes,
    required ProcessingOptions options,
    ProgressCallback? onProgress,
  });

  /// Render a single [element]'s crop with the requested [exportOptions]
  /// background applied (transparent or solid color) and return PNG bytes.
  ///
  /// This is also used for live thumbnail previews in the UI.
  Future<Uint8List> renderElement({
    required DetectedElement element,
    required ExportOptions exportOptions,
  });

  /// Export all applicable elements from [result] to disk.
  ///
  /// Returns the list of file paths written.
  Future<List<String>> exportElements({
    required SegmentationResult result,
    required ExportOptions exportOptions,
    ProgressCallback? onProgress,
  });
}
