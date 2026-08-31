/// Configuration options for the image segmentation engine.
///
/// All fields are serializable to Map<String, dynamic> for isolate passing.
class ProcessingOptions {
  /// Color-match tolerance for background flood-fill (0–255).
  /// Higher = more aggressive background removal.
  final int backgroundTolerance;

  /// Pixels to erode the alpha mask before CCL, separating touching sprites.
  /// 0 = no erosion.
  final int erosionAmount;

  /// Pixels of soft feathering to apply at element edges (0 = hard cutout).
  final int featheringRadius;

  /// Minimum bounding-box area (width × height) to keep a component.
  /// Components smaller than this are discarded as noise.
  final int minElementSize;

  /// Padding added around each element's tight bounding box (pixels).
  final int elementPadding;

  const ProcessingOptions({
    this.backgroundTolerance = 30,
    this.erosionAmount = 1,
    this.featheringRadius = 1,
    this.minElementSize = 100,
    this.elementPadding = 2,
  });

  Map<String, dynamic> toMap() => {
        'backgroundTolerance': backgroundTolerance,
        'erosionAmount': erosionAmount,
        'featheringRadius': featheringRadius,
        'minElementSize': minElementSize,
        'elementPadding': elementPadding,
      };

  factory ProcessingOptions.fromMap(Map<String, dynamic> map) =>
      ProcessingOptions(
        backgroundTolerance: map['backgroundTolerance'] as int? ?? 30,
        erosionAmount: map['erosionAmount'] as int? ?? 1,
        featheringRadius: map['featheringRadius'] as int? ?? 1,
        minElementSize: map['minElementSize'] as int? ?? 100,
        elementPadding: map['elementPadding'] as int? ?? 2,
      );

  ProcessingOptions copyWith({
    int? backgroundTolerance,
    int? erosionAmount,
    int? featheringRadius,
    int? minElementSize,
    int? elementPadding,
  }) =>
      ProcessingOptions(
        backgroundTolerance: backgroundTolerance ?? this.backgroundTolerance,
        erosionAmount: erosionAmount ?? this.erosionAmount,
        featheringRadius: featheringRadius ?? this.featheringRadius,
        minElementSize: minElementSize ?? this.minElementSize,
        elementPadding: elementPadding ?? this.elementPadding,
      );
}
