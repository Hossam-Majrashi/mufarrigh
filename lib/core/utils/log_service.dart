import 'package:flutter/material.dart';

/// Accumulates in-memory diagnostic log entries from engine processing runs.
///
/// Entries are added by [WorkspaceProvider] after each [processSheet] call,
/// using the [diagnosticLog] list returned inside [SegmentationResult].
/// UI can read [entries] and listen for changes.
///
/// Maximum [maxEntries] lines are kept (oldest discarded). Thread-safe for
/// the main isolate only — engine diagnostics are returned via the result.
class LogService extends ChangeNotifier {
  static const int maxEntries = 1000;

  final List<_LogEntry> _entries = [];

  List<_LogEntry> get entries => List.unmodifiable(_entries);

  bool get hasEntries => _entries.isNotEmpty;

  /// Adds a batch of lines (from one engine run) to the buffer.
  void addBatch(String runLabel, List<String> lines) {
    final now = DateTime.now();
    final header = _LogEntry(
      level: LogLevel.info,
      timestamp: now,
      message: '──── $runLabel ────',
    );
    _entries.add(header);
    for (final line in lines) {
      final level = line.toLowerCase().contains('fail') ||
              line.toLowerCase().contains('error')
          ? LogLevel.error
          : line.toLowerCase().contains('warn')
              ? LogLevel.warn
              : LogLevel.info;
      _entries.add(_LogEntry(level: level, timestamp: now, message: line));
    }

    // Trim oldest entries
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    notifyListeners();
  }

  /// Clears all entries.
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Returns all entries as a single copyable string.
  String toPlainText() {
    final buf = StringBuffer();
    for (final e in _entries) {
      final ts = e.timestamp.toIso8601String().substring(11, 23); // HH:mm:ss.mmm
      buf.writeln('[$ts] ${e.message}');
    }
    return buf.toString();
  }
}

enum LogLevel { info, warn, error }

class _LogEntry {
  final LogLevel level;
  final DateTime timestamp;
  final String message;
  const _LogEntry({
    required this.level,
    required this.timestamp,
    required this.message,
  });
}
