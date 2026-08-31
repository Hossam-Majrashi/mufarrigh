// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mufarrigh';

  @override
  String get appSubtitle => 'Sprite Sheet Extractor';

  @override
  String get home => 'Home';

  @override
  String get recentProjects => 'Recent Projects';

  @override
  String get noRecentProjects =>
      'No recent projects yet.\nImport a sprite sheet to get started.';

  @override
  String get newSpriteSheet => 'New Sprite Sheet';

  @override
  String get dropImageHere => 'Drop image here';

  @override
  String get orBrowse => 'or browse files';

  @override
  String get importImage => 'Import Image';

  @override
  String get openRecentProject => 'Open recent project';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get workspace => 'Workspace';

  @override
  String get originalSheet => 'Original Sheet';

  @override
  String get detectedElements => 'Detected Elements';

  @override
  String get properties => 'Properties';

  @override
  String get processing => 'Processing…';

  @override
  String get stepRemovingBackground => 'Removing background…';

  @override
  String get stepDetectingElements => 'Detecting elements…';

  @override
  String get stepExtractingCrops => 'Extracting crops…';

  @override
  String get stepFeathering => 'Feathering edges…';

  @override
  String get stepDone => 'Done';

  @override
  String elementsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements found',
      one: '1 element found',
      zero: 'No elements detected',
    );
    return '$_temp0';
  }

  @override
  String get noElementsFound =>
      'No elements detected.\nTry adjusting detection sensitivity in Settings.';

  @override
  String get element => 'Element';

  @override
  String elementLabel(String number) {
    return 'Element $number';
  }

  @override
  String get deleteElement => 'Delete';

  @override
  String get mergeElements => 'Merge with…';

  @override
  String get splitElement => 'Split';

  @override
  String get renameElement => 'Rename';

  @override
  String get rename => 'Rename';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get background => 'Background';

  @override
  String get transparent => 'Transparent';

  @override
  String get customColor => 'Custom Color';

  @override
  String get globalBackground => 'Global Background';

  @override
  String get perElementOverride => 'Per-Element Override';

  @override
  String get useGlobal => 'Use global';

  @override
  String get clearOverride => 'Clear override';

  @override
  String get export => 'Export';

  @override
  String get exportAll => 'Export All';

  @override
  String exportSelected(int count) {
    return 'Export Selected ($count)';
  }

  @override
  String get chooseFolder => 'Choose Folder';

  @override
  String get exportFolder => 'Export Folder';

  @override
  String get namingScheme => 'Naming Scheme';

  @override
  String get namingSequential => 'Sequential (element_001)';

  @override
  String get namingPosition => 'Position-based (row1_col3)';

  @override
  String get namingCustom => 'Custom names';

  @override
  String exportSuccess(int count, String folder) {
    return '$count files exported to $folder';
  }

  @override
  String exportError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get openFolder => 'Open Folder';

  @override
  String get settings => 'Settings';

  @override
  String get detectionSensitivity => 'Detection Sensitivity';

  @override
  String get detectionSensitivityHint =>
      'Higher = more aggressive background removal';

  @override
  String get minimumElementSize => 'Minimum Element Size';

  @override
  String get minimumElementSizeHint =>
      'Smaller elements are treated as noise and ignored';

  @override
  String get gapErosion => 'Gap Erosion';

  @override
  String get gapErosionHint =>
      'Separates sprites that are touching or overlapping';

  @override
  String get edgeFeathering => 'Edge Feathering';

  @override
  String get edgeFeatheringHint =>
      'Smooths element edges to preserve anti-aliasing';

  @override
  String get elementPadding => 'Element Padding';

  @override
  String get elementPaddingHint =>
      'Extra pixels added around each element\'s bounding box';

  @override
  String get language => 'Language';

  @override
  String get defaultBackground => 'Default Background';

  @override
  String get defaultExportFolder => 'Default Export Folder';

  @override
  String get browse => 'Browse';

  @override
  String get resetDefaults => 'Reset to Defaults';

  @override
  String errorImageLoad(String error) {
    return 'Failed to load image: $error';
  }

  @override
  String errorProcessing(String error) {
    return 'Processing failed: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get retryDetection => 'Retry Detection';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get detectionFailureTitle => 'Could not detect separate elements';

  @override
  String get detectionFailureBody =>
      'Couldn\'t detect separate elements in this sheet. Try adjusting detection sensitivity in Settings, or ensure the background is transparent or uniform in color.';

  @override
  String get confirmDeleteElement => 'Delete this element?';

  @override
  String get confirmDeleteElementBody => 'This action cannot be undone.';

  @override
  String get confirmClearHistory => 'Clear all recent projects?';

  @override
  String get reprocess => 'Re-process Sheet';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get pixels => 'px';

  @override
  String get percent => '%';

  @override
  String get boundingBox => 'Bounding Box';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get position => 'Position';

  @override
  String get size => 'Size';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'Hossam Hassan Majrashi';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get copiedToClipboard => 'Copied to clipboard';
}
