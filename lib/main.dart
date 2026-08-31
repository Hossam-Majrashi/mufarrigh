import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/home/recent_projects_provider.dart';
import 'features/settings/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load SharedPreferences-backed providers before first frame
  final settings = SettingsProvider();
  final recent = RecentProjectsProvider();
  await Future.wait([settings.init(), recent.init()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: recent),
      ],
      child: const MufarrighApp(),
    ),
  );
}
