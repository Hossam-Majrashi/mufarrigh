import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mufarrigh'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sprite Sheet Extractor'**
  String get appSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @recentProjects.
  ///
  /// In en, this message translates to:
  /// **'Recent Projects'**
  String get recentProjects;

  /// No description provided for @noRecentProjects.
  ///
  /// In en, this message translates to:
  /// **'No recent projects yet.\nImport a sprite sheet to get started.'**
  String get noRecentProjects;

  /// No description provided for @newSpriteSheet.
  ///
  /// In en, this message translates to:
  /// **'New Sprite Sheet'**
  String get newSpriteSheet;

  /// No description provided for @dropImageHere.
  ///
  /// In en, this message translates to:
  /// **'Drop image here'**
  String get dropImageHere;

  /// No description provided for @orBrowse.
  ///
  /// In en, this message translates to:
  /// **'or browse files'**
  String get orBrowse;

  /// No description provided for @importImage.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get importImage;

  /// No description provided for @openRecentProject.
  ///
  /// In en, this message translates to:
  /// **'Open recent project'**
  String get openRecentProject;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @originalSheet.
  ///
  /// In en, this message translates to:
  /// **'Original Sheet'**
  String get originalSheet;

  /// No description provided for @detectedElements.
  ///
  /// In en, this message translates to:
  /// **'Detected Elements'**
  String get detectedElements;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @stepRemovingBackground.
  ///
  /// In en, this message translates to:
  /// **'Removing background…'**
  String get stepRemovingBackground;

  /// No description provided for @stepDetectingElements.
  ///
  /// In en, this message translates to:
  /// **'Detecting elements…'**
  String get stepDetectingElements;

  /// No description provided for @stepExtractingCrops.
  ///
  /// In en, this message translates to:
  /// **'Extracting crops…'**
  String get stepExtractingCrops;

  /// No description provided for @stepFeathering.
  ///
  /// In en, this message translates to:
  /// **'Feathering edges…'**
  String get stepFeathering;

  /// No description provided for @stepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stepDone;

  /// No description provided for @elementsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No elements detected} =1{1 element found} other{{count} elements found}}'**
  String elementsFound(int count);

  /// No description provided for @noElementsFound.
  ///
  /// In en, this message translates to:
  /// **'No elements detected.\nTry adjusting detection sensitivity in Settings.'**
  String get noElementsFound;

  /// No description provided for @element.
  ///
  /// In en, this message translates to:
  /// **'Element'**
  String get element;

  /// No description provided for @elementLabel.
  ///
  /// In en, this message translates to:
  /// **'Element {number}'**
  String elementLabel(String number);

  /// No description provided for @deleteElement.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteElement;

  /// No description provided for @mergeElements.
  ///
  /// In en, this message translates to:
  /// **'Merge with…'**
  String get mergeElements;

  /// No description provided for @splitElement.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitElement;

  /// No description provided for @renameElement.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameElement;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @transparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get transparent;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @globalBackground.
  ///
  /// In en, this message translates to:
  /// **'Global Background'**
  String get globalBackground;

  /// No description provided for @perElementOverride.
  ///
  /// In en, this message translates to:
  /// **'Per-Element Override'**
  String get perElementOverride;

  /// No description provided for @useGlobal.
  ///
  /// In en, this message translates to:
  /// **'Use global'**
  String get useGlobal;

  /// No description provided for @clearOverride.
  ///
  /// In en, this message translates to:
  /// **'Clear override'**
  String get clearOverride;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export All'**
  String get exportAll;

  /// No description provided for @exportSelected.
  ///
  /// In en, this message translates to:
  /// **'Export Selected ({count})'**
  String exportSelected(int count);

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get chooseFolder;

  /// No description provided for @exportFolder.
  ///
  /// In en, this message translates to:
  /// **'Export Folder'**
  String get exportFolder;

  /// No description provided for @namingScheme.
  ///
  /// In en, this message translates to:
  /// **'Naming Scheme'**
  String get namingScheme;

  /// No description provided for @namingSequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential (element_001)'**
  String get namingSequential;

  /// No description provided for @namingPosition.
  ///
  /// In en, this message translates to:
  /// **'Position-based (row1_col3)'**
  String get namingPosition;

  /// No description provided for @namingCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom names'**
  String get namingCustom;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} files exported to {folder}'**
  String exportSuccess(int count, String folder);

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportError(String error);

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @detectionSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Detection Sensitivity'**
  String get detectionSensitivity;

  /// No description provided for @detectionSensitivityHint.
  ///
  /// In en, this message translates to:
  /// **'Higher = more aggressive background removal'**
  String get detectionSensitivityHint;

  /// No description provided for @minimumElementSize.
  ///
  /// In en, this message translates to:
  /// **'Minimum Element Size'**
  String get minimumElementSize;

  /// No description provided for @minimumElementSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Smaller elements are treated as noise and ignored'**
  String get minimumElementSizeHint;

  /// No description provided for @gapErosion.
  ///
  /// In en, this message translates to:
  /// **'Gap Erosion'**
  String get gapErosion;

  /// No description provided for @gapErosionHint.
  ///
  /// In en, this message translates to:
  /// **'Separates sprites that are touching or overlapping'**
  String get gapErosionHint;

  /// No description provided for @edgeFeathering.
  ///
  /// In en, this message translates to:
  /// **'Edge Feathering'**
  String get edgeFeathering;

  /// No description provided for @edgeFeatheringHint.
  ///
  /// In en, this message translates to:
  /// **'Smooths element edges to preserve anti-aliasing'**
  String get edgeFeatheringHint;

  /// No description provided for @elementPadding.
  ///
  /// In en, this message translates to:
  /// **'Element Padding'**
  String get elementPadding;

  /// No description provided for @elementPaddingHint.
  ///
  /// In en, this message translates to:
  /// **'Extra pixels added around each element\'s bounding box'**
  String get elementPaddingHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @defaultBackground.
  ///
  /// In en, this message translates to:
  /// **'Default Background'**
  String get defaultBackground;

  /// No description provided for @defaultExportFolder.
  ///
  /// In en, this message translates to:
  /// **'Default Export Folder'**
  String get defaultExportFolder;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @resetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetDefaults;

  /// No description provided for @errorImageLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image: {error}'**
  String errorImageLoad(String error);

  /// No description provided for @errorProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing failed: {error}'**
  String errorProcessing(String error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retryDetection.
  ///
  /// In en, this message translates to:
  /// **'Retry Detection'**
  String get retryDetection;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @detectionFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not detect separate elements'**
  String get detectionFailureTitle;

  /// No description provided for @detectionFailureBody.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t detect separate elements in this sheet. Try adjusting detection sensitivity in Settings, or ensure the background is transparent or uniform in color.'**
  String get detectionFailureBody;

  /// No description provided for @confirmDeleteElement.
  ///
  /// In en, this message translates to:
  /// **'Delete this element?'**
  String get confirmDeleteElement;

  /// No description provided for @confirmDeleteElementBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteElementBody;

  /// No description provided for @confirmClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear all recent projects?'**
  String get confirmClearHistory;

  /// No description provided for @reprocess.
  ///
  /// In en, this message translates to:
  /// **'Re-process Sheet'**
  String get reprocess;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @pixels.
  ///
  /// In en, this message translates to:
  /// **'px'**
  String get pixels;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @boundingBox.
  ///
  /// In en, this message translates to:
  /// **'Bounding Box'**
  String get boundingBox;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'Hossam Hassan Majrashi'**
  String get developerName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
