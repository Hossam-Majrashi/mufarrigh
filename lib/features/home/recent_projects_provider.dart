import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A record of a recently opened sprite sheet project.
class RecentProject {
  final String imagePath;
  final String? displayName;
  final DateTime openedAt;
  final int elementCount;

  const RecentProject({
    required this.imagePath,
    this.displayName,
    required this.openedAt,
    this.elementCount = 0,
  });

  String get name => displayName ?? imagePath.split('/').last.split('\\').last;

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'displayName': displayName,
        'openedAt': openedAt.toIso8601String(),
        'elementCount': elementCount,
      };

  factory RecentProject.fromJson(Map<String, dynamic> json) => RecentProject(
        imagePath: json['imagePath'] as String,
        displayName: json['displayName'] as String?,
        openedAt: DateTime.parse(json['openedAt'] as String),
        elementCount: json['elementCount'] as int? ?? 0,
      );
}

/// Manages the list of recently opened sprite sheet projects.
class RecentProjectsProvider extends ChangeNotifier {
  static const _key = 'recentProjects';
  static const _maxItems = 20;

  late SharedPreferences _prefs;
  List<RecentProject> _projects = [];

  List<RecentProject> get projects => List.unmodifiable(_projects);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    final raw = _prefs.getStringList(_key) ?? [];
    _projects = raw
        .map((s) {
          try {
            return RecentProject.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<RecentProject>()
        .toList()
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    notifyListeners();
  }

  Future<void> add({
    required String imagePath,
    String? displayName,
    int elementCount = 0,
  }) async {
    // Remove any existing entry with same path
    _projects.removeWhere((p) => p.imagePath == imagePath);

    _projects.insert(
      0,
      RecentProject(
        imagePath: imagePath,
        displayName: displayName,
        openedAt: DateTime.now(),
        elementCount: elementCount,
      ),
    );

    if (_projects.length > _maxItems) {
      _projects = _projects.sublist(0, _maxItems);
    }

    await _save();
    notifyListeners();
  }

  Future<void> remove(String imagePath) async {
    _projects.removeWhere((p) => p.imagePath == imagePath);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _projects = [];
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final raw = _projects.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_key, raw);
  }
}
