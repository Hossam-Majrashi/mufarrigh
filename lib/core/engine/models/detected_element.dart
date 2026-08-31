import 'dart:typed_data';
import 'dart:ui' show Color;

/// Represents one detected visual element extracted from a sprite sheet.
class DetectedElement {
  /// Unique sequential identifier, e.g. "element_001".
  final String id;

  /// Zero-based index (original detection order).
  final int index;

  /// User-editable display name (defaults to [id]).
  final String? customName;

  /// Bounding box in the coordinate space of the original sheet image.
  final int x;
  final int y;
  final int width;
  final int height;

  /// PNG-encoded crop of this element with alpha channel (background removed).
  final Uint8List cropBytes;

  /// Per-element background color override.
  /// - null → use the global workspace background setting
  /// - Color(0x00000000) → force transparent
  /// - any other Color → fill with that color
  final Color? backgroundColorOverride;

  /// Whether the per-element override is active.
  bool get hasColorOverride => backgroundColorOverride != null;

  const DetectedElement({
    required this.id,
    required this.index,
    this.customName,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.cropBytes,
    this.backgroundColorOverride,
  });

  String get displayName => customName ?? id;

  /// Row/column position label (e.g. "row1_col3") — approximate.
  String positionalName(int totalWidth, int totalHeight) {
    final col = (x / (totalWidth / 8)).round() + 1;
    final row = (y / (totalHeight / 8)).round() + 1;
    return 'row${row}_col$col';
  }

  DetectedElement copyWith({
    String? id,
    int? index,
    String? customName,
    bool clearCustomName = false,
    int? x,
    int? y,
    int? width,
    int? height,
    Uint8List? cropBytes,
    Color? backgroundColorOverride,
    bool clearBackgroundOverride = false,
  }) =>
      DetectedElement(
        id: id ?? this.id,
        index: index ?? this.index,
        customName: clearCustomName ? null : (customName ?? this.customName),
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
        cropBytes: cropBytes ?? this.cropBytes,
        backgroundColorOverride: clearBackgroundOverride
            ? null
            : (backgroundColorOverride ?? this.backgroundColorOverride),
      );

  /// Serialize to Map for isolate transfer (cropBytes sent separately).
  Map<String, dynamic> toMap() => {
        'id': id,
        'index': index,
        'customName': customName,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        // cropBytes passed separately as typed list
      };

  factory DetectedElement.fromMap(
    Map<String, dynamic> map,
    Uint8List cropBytes,
  ) =>
      DetectedElement(
        id: map['id'] as String,
        index: map['index'] as int,
        customName: map['customName'] as String?,
        x: map['x'] as int,
        y: map['y'] as int,
        width: map['width'] as int,
        height: map['height'] as int,
        cropBytes: cropBytes,
      );
}
