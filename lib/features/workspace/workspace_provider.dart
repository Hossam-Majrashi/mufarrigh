import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../core/engine/dart_image_engine.dart';
import '../../core/engine/image_engine.dart';
import '../../core/utils/log_service.dart';

enum ProcessingState { idle, processing, done, error }

/// Main state provider for the Workspace screen.
///
/// Owns the entire image-processing lifecycle:
///   loading → processing → reviewing → exporting
class WorkspaceProvider extends ChangeNotifier {
  final ImageEngine _engine;
  LogService? _logService;

  WorkspaceProvider({ImageEngine? engine})
      : _engine = engine ?? const DartImageEngine();

  /// Attach a [LogService] so engine diagnostics are forwarded after each run.
  void attachLogService(LogService service) {
    _logService = service;
  }

  // ── Processing pipeline state ─────────────────────────────────
  ProcessingState _state = ProcessingState.idle;
  String _processingStep = '';
  double _processingProgress = 0;
  String? _errorMessage;

  // ── Image data ────────────────────────────────────────────────
  Uint8List? _originalImageBytes;
  String? _imagePath;
  SegmentationResult? _result;

  // ── UI selection state ────────────────────────────────────────
  int? _selectedElementIndex;
  final Set<int> _selectedForExport = {};

  // ── Background settings ───────────────────────────────────────
  Color? _globalBackgroundColor; // null = transparent

  // ── Getters ───────────────────────────────────────────────────
  ProcessingState get state => _state;
  String get processingStep => _processingStep;
  double get processingProgress => _processingProgress;
  String? get errorMessage => _errorMessage;
  Uint8List? get originalImageBytes => _originalImageBytes;
  String? get imagePath => _imagePath;
  SegmentationResult? get result => _result;
  int? get selectedElementIndex => _selectedElementIndex;
  Set<int> get selectedForExport => Set.unmodifiable(_selectedForExport);
  Color? get globalBackgroundColor => _globalBackgroundColor;
  bool get hasResult => _result != null;
  bool get isProcessing => _state == ProcessingState.processing;
  List<DetectedElement> get elements => _result?.elements ?? [];

  /// The source image filename without extension, suitable as a folder name.
  /// E.g. "/home/user/sprites.png" → "sprites"
  String get imageFilenameStem {
    final path = _imagePath;
    if (path == null || path.isEmpty) return 'sprites';
    final base = path.split('/').last.split('\\').last;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  DetectedElement? get selectedElement => _selectedElementIndex != null &&
          _selectedElementIndex! < elements.length
      ? elements[_selectedElementIndex!]
      : null;

  // ── Load & process ────────────────────────────────────────────

  Future<void> loadImage(
    Uint8List bytes,
    String path,
    ProcessingOptions options,
  ) async {
    _originalImageBytes = bytes;
    _imagePath = path;
    _result = null;
    _selectedElementIndex = null;
    _selectedForExport.clear();
    _state = ProcessingState.processing;
    _processingStep = 'Removing background…';
    _processingProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Run processing in isolate via DartImageEngine
      final result = await _engine.processSheet(
        imageBytes: bytes,
        options: options,
        onProgress: (step, progress) {
          _processingStep = step;
          _processingProgress = progress;
          notifyListeners();
        },
      );

      _result = result;
      _state = ProcessingState.done;
      _processingStep = 'Done';
      _processingProgress = 1.0;
      // Forward engine diagnostic log to LogService
      if (result.diagnosticLog.isNotEmpty) {
        _logService?.addBatch(
          'Run: ${_imagePath?.split('/').last ?? 'unknown'}',
          result.diagnosticLog,
        );
      }
    } catch (e) {
      _state = ProcessingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> reprocess(ProcessingOptions options) async {
    if (_originalImageBytes == null) return;
    await loadImage(_originalImageBytes!, _imagePath ?? '', options);
  }

  // ── Selection ─────────────────────────────────────────────────

  void selectElement(int index) {
    _selectedElementIndex = index;
    notifyListeners();
  }

  void clearSelection() {
    _selectedElementIndex = null;
    notifyListeners();
  }

  void toggleExportSelection(int index) {
    if (_selectedForExport.contains(index)) {
      _selectedForExport.remove(index);
    } else {
      _selectedForExport.add(index);
    }
    notifyListeners();
  }

  void selectAllForExport() {
    _selectedForExport.addAll(
      List.generate(elements.length, (i) => i),
    );
    notifyListeners();
  }

  void deselectAllForExport() {
    _selectedForExport.clear();
    notifyListeners();
  }

  // ── Element editing ───────────────────────────────────────────

  void deleteElement(int index) {
    if (_result == null) return;
    final updated = List<DetectedElement>.from(elements)..removeAt(index);
    _result = _result!.withRenumberedElements(updated);
    if (_selectedElementIndex == index) {
      _selectedElementIndex = null;
    } else if (_selectedElementIndex != null &&
        _selectedElementIndex! > index) {
      _selectedElementIndex = _selectedElementIndex! - 1;
    }
    _selectedForExport.remove(index);
    notifyListeners();
  }

  void renameElement(int index, String newName) {
    if (_result == null || index >= elements.length) return;
    final el = elements[index];
    final updated = List<DetectedElement>.from(elements)
      ..[index] = el.copyWith(customName: newName.isEmpty ? null : newName,
          clearCustomName: newName.isEmpty);
    _result = _result!.copyWith(elements: updated);
    notifyListeners();
  }

  void updateElementBounds(
      int index, int x, int y, int width, int height) {
    if (_result == null || _originalImageBytes == null) return;
    final el = elements[index];
    final updated = List<DetectedElement>.from(elements)
      ..[index] = el.copyWith(x: x, y: y, width: width, height: height);
    _result = _result!.copyWith(elements: updated);
    notifyListeners();
    // Re-crop element from processed sheet
    _recropElement(index, x, y, width, height);
  }

  Future<void> _recropElement(
      int index, int x, int y, int width, int height) async {
    if (_result == null) return;
    // Compute re-crop in background
    final sheetBytes = _result!.processedSheetBytes;
    final cropBytes = await compute(
      _cropFromSheet,
      {'sheetBytes': sheetBytes, 'x': x, 'y': y, 'w': width, 'h': height},
    );
    if (_result == null || index >= elements.length) return;
    final updated = List<DetectedElement>.from(elements)
      ..[index] = elements[index].copyWith(cropBytes: cropBytes);
    _result = _result!.copyWith(elements: updated);
    notifyListeners();
  }

  static Uint8List _cropFromSheet(Map<String, dynamic> params) {
    final bytes = params['sheetBytes'] as Uint8List;
    final x = params['x'] as int;
    final y = params['y'] as int;
    final w = params['w'] as int;
    final h = params['h'] as int;
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    final crop = img.copyCrop(image, x: x, y: y, width: w, height: h);
    return Uint8List.fromList(img.encodePng(crop));
  }

  void setElementBackgroundOverride(int index, Color? color) {
    if (_result == null || index >= elements.length) return;
    final el = elements[index];
    final updated = List<DetectedElement>.from(elements)
      ..[index] = el.copyWith(
          backgroundColorOverride: color, clearBackgroundOverride: color == null);
    _result = _result!.copyWith(elements: updated);
    notifyListeners();
  }

  // ── Global background ─────────────────────────────────────────

  void setGlobalBackground(Color? color) {
    _globalBackgroundColor = color;
    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────

  void reset() {
    _state = ProcessingState.idle;
    _originalImageBytes = null;
    _imagePath = null;
    _result = null;
    _selectedElementIndex = null;
    _selectedForExport.clear();
    _globalBackgroundColor = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Export helpers ────────────────────────────────────────────

  ExportOptions buildExportOptions({
    required String outputFolder,
    required String namingScheme,
    bool exportSelectedOnly = false,
  }) {
    return ExportOptions(
      outputFolder: outputFolder,
      namingScheme: switch (namingScheme) {
        'positional' => NamingScheme.positional,
        'custom' => NamingScheme.custom,
        _ => NamingScheme.sequential,
      },
      globalBackgroundColor: _globalBackgroundColor,
      exportSelectedOnly: exportSelectedOnly,
      selectedIndices: _selectedForExport.toList()..sort(),
    );
  }
}
