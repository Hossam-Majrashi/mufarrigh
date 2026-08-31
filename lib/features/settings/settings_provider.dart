import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/engine/models/processing_options.dart';

/// Application settings persisted via SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  static const _keyLocale = 'locale';
  static const _keyBgTolerance = 'bgTolerance';
  static const _keyErosion = 'erosionAmount';
  static const _keyFeathering = 'featheringRadius';
  static const _keyMinSize = 'minElementSize';
  static const _keyPadding = 'elementPadding';
  static const _keyExportFolder = 'exportFolder';
  static const _keyGlobalBgColor = 'globalBgColor';
  static const _keyNamingScheme = 'namingScheme';

  late SharedPreferences _prefs;

  // ── State ────────────────────────────────────────────────────
  String _locale = 'en';
  ProcessingOptions _processingOptions = const ProcessingOptions();
  String _exportFolder = '';
  int? _globalBgColor; // null = transparent
  String _namingScheme = 'sequential';

  // ── Supported locales ────────────────────────────────────────
  /// Arabic first, then English, then the rest (BCP-47 codes).
  static const List<({String code, String nativeName})> supportedLocales = [
    (code: 'ar', nativeName: 'العربية'),
    (code: 'en', nativeName: 'English'),
    (code: 'fr', nativeName: 'Français'),
    (code: 'es', nativeName: 'Español'),
    (code: 'de', nativeName: 'Deutsch'),
    (code: 'zh', nativeName: '中文'),
    (code: 'ja', nativeName: '日本語'),
    (code: 'ko', nativeName: '한국어'),
    (code: 'tr', nativeName: 'Türkçe'),
    (code: 'pt', nativeName: 'Português'),
    (code: 'it', nativeName: 'Italiano'),
    (code: 'ru', nativeName: 'Русский'),
    (code: 'pl', nativeName: 'Polski'),
    (code: 'nl', nativeName: 'Nederlands'),
    (code: 'id', nativeName: 'Indonesia'),
    (code: 'hi', nativeName: 'हिन्दी'),
    (code: 'fa', nativeName: 'فارسی'),
    (code: 'ur', nativeName: 'اردو'),
    (code: 'th', nativeName: 'ภาษาไทย'),
    (code: 'vi', nativeName: 'Tiếng Việt'),
  ];

  // ── Getters ──────────────────────────────────────────────────
  String get locale => _locale;
  ProcessingOptions get processingOptions => _processingOptions;
  String get exportFolder => _exportFolder;
  int? get globalBgColor => _globalBgColor;
  bool get isTransparentBackground => _globalBgColor == null;
  String get namingScheme => _namingScheme;

  // ── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _locale = _prefs.getString(_keyLocale) ?? _deviceLocale();
    _processingOptions = ProcessingOptions(
      backgroundTolerance: _prefs.getInt(_keyBgTolerance) ?? 30,
      erosionAmount: _prefs.getInt(_keyErosion) ?? 1,
      featheringRadius: _prefs.getInt(_keyFeathering) ?? 1,
      minElementSize: _prefs.getInt(_keyMinSize) ?? 100,
      elementPadding: _prefs.getInt(_keyPadding) ?? 2,
    );
    _exportFolder = _prefs.getString(_keyExportFolder) ?? '';
    _globalBgColor = _prefs.containsKey(_keyGlobalBgColor)
        ? _prefs.getInt(_keyGlobalBgColor)
        : null;
    _namingScheme = _prefs.getString(_keyNamingScheme) ?? 'sequential';
    notifyListeners();
  }

  // ── Setters ──────────────────────────────────────────────────
  Future<void> setLocale(String code) async {
    _locale = code;
    await _prefs.setString(_keyLocale, code);
    notifyListeners();
  }

  Future<void> setBackgroundTolerance(int value) async {
    _processingOptions =
        _processingOptions.copyWith(backgroundTolerance: value);
    await _prefs.setInt(_keyBgTolerance, value);
    notifyListeners();
  }

  Future<void> setErosionAmount(int value) async {
    _processingOptions = _processingOptions.copyWith(erosionAmount: value);
    await _prefs.setInt(_keyErosion, value);
    notifyListeners();
  }

  Future<void> setFeatheringRadius(int value) async {
    _processingOptions = _processingOptions.copyWith(featheringRadius: value);
    await _prefs.setInt(_keyFeathering, value);
    notifyListeners();
  }

  Future<void> setMinElementSize(int value) async {
    _processingOptions = _processingOptions.copyWith(minElementSize: value);
    await _prefs.setInt(_keyMinSize, value);
    notifyListeners();
  }

  Future<void> setElementPadding(int value) async {
    _processingOptions = _processingOptions.copyWith(elementPadding: value);
    await _prefs.setInt(_keyPadding, value);
    notifyListeners();
  }

  Future<void> setExportFolder(String folder) async {
    _exportFolder = folder;
    await _prefs.setString(_keyExportFolder, folder);
    notifyListeners();
  }

  Future<void> setGlobalBgColor(int? argbColor) async {
    _globalBgColor = argbColor;
    if (argbColor == null) {
      await _prefs.remove(_keyGlobalBgColor);
    } else {
      await _prefs.setInt(_keyGlobalBgColor, argbColor);
    }
    notifyListeners();
  }

  Future<void> setNamingScheme(String scheme) async {
    _namingScheme = scheme;
    await _prefs.setString(_keyNamingScheme, scheme);
    notifyListeners();
  }

  Future<void> resetDefaults() async {
    _processingOptions = const ProcessingOptions();
    _globalBgColor = null;
    _namingScheme = 'sequential';
    await _prefs.remove(_keyBgTolerance);
    await _prefs.remove(_keyErosion);
    await _prefs.remove(_keyFeathering);
    await _prefs.remove(_keyMinSize);
    await _prefs.remove(_keyPadding);
    await _prefs.remove(_keyGlobalBgColor);
    await _prefs.remove(_keyNamingScheme);
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────
  String _deviceLocale() {
    // Default to Arabic, then system locale
    try {
      final sysLocale = PlatformDispatcher.instance.locale.languageCode;
      final supported = supportedLocales.map((l) => l.code).toSet();
      if (supported.contains(sysLocale)) return sysLocale;
    } catch (_) {}
    return 'ar';
  }
}
