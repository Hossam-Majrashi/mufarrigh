import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/log_service.dart';
import 'features/export/export_service.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_provider.dart';
import 'features/settings/settings_screen.dart';
import 'features/workspace/workspace_provider.dart';

/// Root of the Mufarrigh application.
class MufarrighApp extends StatelessWidget {
  const MufarrighApp({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: SettingsProvider and RecentProjectsProvider are already injected by
    // main.dart (pre-initialized before first frame). Only add providers here
    // that do NOT require async init.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LogService()),
        ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => ExportService()),
      ],
      child: Builder(
        builder: (ctx) {
          // Attach LogService to WorkspaceProvider so engine diagnostics
          // are forwarded to the log buffer after each processing run.
          ctx.read<WorkspaceProvider>().attachLogService(
            ctx.read<LogService>(),
          );
          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return MaterialApp(
                title: 'مُفرِّغ — Mufarrigh',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.dark,

                // Localization
                locale: Locale(settings.locale),
                supportedLocales: SettingsProvider.supportedLocales
                    .map((l) => Locale(l.code))
                    .toList(),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // Routes
                initialRoute: '/',
                routes: {
                  '/': (_) => const HomeScreen(),
                  '/settings': (_) => const SettingsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
