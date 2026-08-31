import 'package:flutter/foundation.dart';
import '../../core/engine/dart_image_engine.dart';
import '../../core/engine/image_engine.dart';

enum ExportState { idle, exporting, done, error }

/// Manages the export process and tracks progress.
class ExportService extends ChangeNotifier {
  final ImageEngine _engine;

  ExportService({ImageEngine? engine})
      : _engine = engine ?? const DartImageEngine();

  ExportState _state = ExportState.idle;
  double _progress = 0;
  String _progressStep = '';
  String? _errorMessage;
  List<String> _exportedPaths = [];

  ExportState get state => _state;
  double get progress => _progress;
  String get progressStep => _progressStep;
  String? get errorMessage => _errorMessage;
  List<String> get exportedPaths => List.unmodifiable(_exportedPaths);
  bool get isExporting => _state == ExportState.exporting;
  int get exportedCount => _exportedPaths.length;

  Future<bool> export({
    required SegmentationResult result,
    required ExportOptions options,
  }) async {
    _state = ExportState.exporting;
    _progress = 0;
    _progressStep = 'Preparing…';
    _errorMessage = null;
    _exportedPaths = [];
    notifyListeners();

    try {
      final paths = await _engine.exportElements(
        result: result,
        exportOptions: options,
        onProgress: (step, progress) {
          _progressStep = step;
          _progress = progress;
          notifyListeners();
        },
      );

      _exportedPaths = paths;
      _state = ExportState.done;
      _progress = 1.0;
      _progressStep = 'Done';
      notifyListeners();
      return true;
    } catch (e) {
      _state = ExportState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = ExportState.idle;
    _progress = 0;
    _progressStep = '';
    _errorMessage = null;
    _exportedPaths = [];
    notifyListeners();
  }
}
