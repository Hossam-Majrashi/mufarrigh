import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/log_service.dart';
import '../../shared/widgets/color_picker_button.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDeep,
        title: const Text('Settings', style: AppTheme.titleMedium),
        actions: [
          TextButton(
            onPressed: () => context.read<SettingsProvider>().resetDefaults(),
            child: Text('Reset',
                style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.onSurfaceDim)),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _SectionHeader('Detection'),
              _SliderTile(
                label: 'Detection Sensitivity',
                hint: 'Higher = more aggressive background removal',
                value: settings.processingOptions.backgroundTolerance.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                onChanged: (v) =>
                    settings.setBackgroundTolerance(v.round()),
              ),
              _SliderTile(
                label: 'Minimum Element Size',
                hint: 'Smaller elements treated as noise',
                value: settings.processingOptions.minElementSize.toDouble(),
                min: 10,
                max: 2000,
                divisions: 40,
                onChanged: (v) => settings.setMinElementSize(v.round()),
              ),
              _SliderTile(
                label: 'Gap Erosion',
                hint: 'Separates touching sprites before detection',
                value: settings.processingOptions.erosionAmount.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (v) => settings.setErosionAmount(v.round()),
              ),
              _SliderTile(
                label: 'Edge Feathering',
                hint: 'Smooths element edges, preserves anti-aliasing',
                value: settings.processingOptions.featheringRadius.toDouble(),
                min: 0,
                max: 4,
                divisions: 4,
                onChanged: (v) => settings.setFeatheringRadius(v.round()),
              ),
              _SliderTile(
                label: 'Element Padding',
                hint: 'Extra pixels around each bounding box',
                value: settings.processingOptions.elementPadding.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                onChanged: (v) => settings.setElementPadding(v.round()),
              ),

              const SizedBox(height: 8),
              _SectionHeader('Export'),

              _Tile(
                label: 'Default Background',
                child: ColorPickerButton(
                  color: settings.globalBgColor != null
                      ? Color(settings.globalBgColor!)
                      : null,
                  label: 'Default Background',
                  onColorChanged: (c) =>
                      settings.setGlobalBgColor(c?.value),
                ),
              ),

              _Tile(
                label: 'Default Export Folder',
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfacePanelBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          settings.exportFolder.isEmpty
                              ? 'Not set (will prompt on export)'
                              : settings.exportFolder,
                          style: AppTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final folder = await FileUtils.pickOutputFolder();
                        if (folder != null) {
                          settings.setExportFolder(folder);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(72, 42)),
                      child: const Text('Browse'),
                    ),
                  ],
                ),
              ),

              _Tile(
                label: 'Naming Scheme',
                child: DropdownButtonFormField<String>(
                  value: settings.namingScheme,
                  dropdownColor: AppTheme.surfaceCard,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfacePanelBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'sequential',
                        child: Text('Sequential (element_001)')),
                    DropdownMenuItem(
                        value: 'positional',
                        child: Text('Position-based (row1_col3)')),
                    DropdownMenuItem(
                        value: 'custom', child: Text('Custom names')),
                  ],
                  onChanged: (v) {
                    if (v != null) settings.setNamingScheme(v);
                  },
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader('App'),

              _Tile(
                label: 'Language',
                child: DropdownButtonFormField<String>(
                  value: settings.locale,
                  dropdownColor: AppTheme.surfaceCard,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfacePanelBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  items: SettingsProvider.supportedLocales
                      .map((loc) => DropdownMenuItem(
                            value: loc.code,
                            child: Text('${loc.nativeName} (${loc.code})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) settings.setLocale(v);
                  },
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(AppLocalizations.of(context).developer),
              const _DeveloperCard(),

              const SizedBox(height: 8),
              const _SectionHeader('Diagnostics'),
              const _LogsPanel(),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.labelMedium,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final String hint;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTheme.bodyMedium)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value.round().toString(),
                  style: AppTheme.bodySmall
                      .copyWith(color: AppTheme.accentPrimary),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
          Text(hint, style: AppTheme.bodySmall),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final Widget child;
  const _Tile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Diagnostic Logs Panel
// ──────────────────────────────────────────────────────────────

class _LogsPanel extends StatefulWidget {
  const _LogsPanel();

  @override
  State<_LogsPanel> createState() => _LogsPanelState();
}

class _LogsPanelState extends State<_LogsPanel> {
  final ScrollController _scroll = ScrollController();
  bool _copied = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogService>(
      builder: (context, logService, _) {
        final entries = logService.entries;
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.terminal_outlined,
                        size: 16, color: AppTheme.onSurfaceMid),
                    const SizedBox(width: 8),
                    Text(
                      'Engine Logs',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.onSurfaceMid),
                    ),
                    const Spacer(),
                    if (logService.hasEntries) ...[
                      // Copy All
                      _ActionChip(
                        icon: _copied
                            ? Icons.check
                            : Icons.copy_outlined,
                        label: _copied ? 'Copied!' : 'Copy All',
                        color: _copied
                            ? AppTheme.accentSecondary
                            : AppTheme.accentPrimary,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: logService.toPlainText()),
                          );
                          setState(() => _copied = true);
                          Future.delayed(
                            const Duration(seconds: 2),
                            () {
                              if (mounted) setState(() => _copied = false);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Clear
                      _ActionChip(
                        icon: Icons.delete_outline,
                        label: 'Clear',
                        color: AppTheme.onSurfaceDim,
                        onTap: logService.clear,
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.divider),

              // Log lines
              if (!logService.hasEntries)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No logs yet. Load a sprite sheet to see engine diagnostics.',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceDim),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: Scrollbar(
                    controller: _scroll,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: entries.length,
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      itemBuilder: (_, i) {
                        final entry = entries[i];
                        final isHeader =
                            entry.message.startsWith('────');
                        final isError =
                            entry.level == LogLevel.error;
                        final color = isHeader
                            ? AppTheme.accentPrimary
                            : isError
                                ? AppTheme.error
                                : AppTheme.onSurfaceMid;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            entry.message,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              color: color,
                              fontWeight: isHeader
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Developer Card
// ──────────────────────────────────────────────────────────────

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  static Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تعذر فتح الرابط: $urlString')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الرابط: $e')),
        );
      }
    }
  }

  static Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfacePanelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.hoverBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.accentPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.onSurfaceMid,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'نسخ',
                  color: AppTheme.onSurfaceDim,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم نسخ $label'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppTheme.onSurfaceDim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.onPrimaryButton,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حسام حسن مجرشي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Software Developer | مطور برمجيات',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 32),
          _buildContactItem(
            context,
            icon: Icons.alternate_email_rounded,
            label: 'البريد الإلكتروني',
            value: 'Hossam.Majrashi@gmail.com',
            onTap: () => _launchUrl(context, 'mailto:Hossam.Majrashi@gmail.com'),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            context,
            icon: Icons.public_rounded,
            label: 'الموقع الإلكتروني',
            value: 'hossam-majrashi.github.io/Works/',
            onTap: () =>
                _launchUrl(context, 'https://hossam-majrashi.github.io/Works/'),
          ),
        ],
      ),
    );
  }
}

