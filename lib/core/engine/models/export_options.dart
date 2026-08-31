import 'dart:ui' show Color;

/// Naming scheme for exported element files.
enum NamingScheme {
  /// element_001.png, element_002.png, ...
  sequential,

  /// row1_col3.png (approximate grid position)
  positional,

  /// Uses [DetectedElement.customName] if set, falls back to sequential.
  custom,
}

/// Options controlling how detected elements are exported to disk.
class ExportOptions {
  /// Folder path where exported PNGs will be written.
  final String outputFolder;

  /// File naming scheme.
  final NamingScheme namingScheme;

  /// Global background color for all exported elements.
  /// - null → transparent (alpha preserved)
  /// - Color → fill background with this color before export
  ///
  /// Individual elements can override this via [DetectedElement.backgroundColorOverride].
  final Color? globalBackgroundColor;

  /// If true, only export elements in [selectedIndices].
  final bool exportSelectedOnly;

  /// Indices of elements to export (only used when [exportSelectedOnly] is true).
  final List<int> selectedIndices;

  const ExportOptions({
    required this.outputFolder,
    this.namingScheme = NamingScheme.sequential,
    this.globalBackgroundColor,
    this.exportSelectedOnly = false,
    this.selectedIndices = const [],
  });

  ExportOptions copyWith({
    String? outputFolder,
    NamingScheme? namingScheme,
    Color? globalBackgroundColor,
    bool clearGlobalBackground = false,
    bool? exportSelectedOnly,
    List<int>? selectedIndices,
  }) =>
      ExportOptions(
        outputFolder: outputFolder ?? this.outputFolder,
        namingScheme: namingScheme ?? this.namingScheme,
        globalBackgroundColor: clearGlobalBackground
            ? null
            : (globalBackgroundColor ?? this.globalBackgroundColor),
        exportSelectedOnly: exportSelectedOnly ?? this.exportSelectedOnly,
        selectedIndices: selectedIndices ?? this.selectedIndices,
      );
}
