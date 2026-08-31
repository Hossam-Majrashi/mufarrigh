import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_utils.dart';
import '../../shared/widgets/app_progress_indicator.dart';
import '../settings/settings_provider.dart';
import '../workspace/workspace_provider.dart';
import 'export_service.dart';

/// Modal bottom sheet for configuring and triggering an export.
///
/// Lets the user choose:
/// - A **base folder** (the parent directory)
/// - A **subfolder name** (defaults to the source image filename stem)
///   so the final path is  <base>/<subfolder>/<element_001.png>
/// - Naming scheme
/// - Whether to export all or only selected elements
class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late String _baseFolder;
  late TextEditingController _subfolderCtrl;
  late String _namingScheme;
  bool _exportSelectedOnly = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    final workspace = context.read<WorkspaceProvider>();

    _baseFolder = settings.exportFolder;
    // Default subfolder = source image filename stem (e.g. "sprites" for sprites.png)
    _subfolderCtrl = TextEditingController(text: workspace.imageFilenameStem);
    _namingScheme = settings.namingScheme;
    _exportSelectedOnly = workspace.selectedForExport.isNotEmpty;
  }

  @override
  void dispose() {
    _subfolderCtrl.dispose();
    super.dispose();
  }

  /// The resolved output folder: <base>/<subfolder> if subfolder is non-empty,
  /// otherwise just <base>.
  String get _resolvedOutputFolder {
    final sub = _subfolderCtrl.text.trim();
    if (sub.isEmpty) return _baseFolder;
    return p.join(_baseFolder, FileUtils.sanitizeFilename(sub));
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final exportSvc = context.watch<ExportService>();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (exportSvc.isExporting)
                _exportingState(exportSvc)
              else if (exportSvc.state == ExportState.done)
                _doneState(exportSvc)
              else if (exportSvc.state == ExportState.error)
                _errorState(exportSvc)
              else
                _configState(context, workspace),
            ],
          ),
        ),
      ),
    );
  }

  Widget _configState(BuildContext context, WorkspaceProvider workspace) {
    final selectedCount = workspace.selectedForExport.length;
    final totalCount = workspace.elements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.upload_outlined, color: AppTheme.accentPrimary),
            const SizedBox(width: 12),
            Text('Export Elements', style: AppTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 20),

        // ── Export scope ──────────────────────────────────────────
        if (selectedCount > 0) ...[
          _ConfigRow(
            label: 'Export scope',
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text('All ($totalCount)')),
                ButtonSegment(
                    value: true, label: Text('Selected ($selectedCount)')),
              ],
              selected: {_exportSelectedOnly},
              onSelectionChanged: (s) =>
                  setState(() => _exportSelectedOnly = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? AppTheme.selectedBg
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Base folder ───────────────────────────────────────────
        _ConfigRow(
          label: 'Parent folder',
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
                    _baseFolder.isEmpty
                        ? 'Tap Browse to select…'
                        : _baseFolder,
                    style: AppTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final f = await FileUtils.pickOutputFolder();
                  if (f != null) setState(() => _baseFolder = f);
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(72, 40)),
                child: const Text('Browse'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Subfolder name ────────────────────────────────────────
        _ConfigRow(
          label: 'Subfolder name',
          hint:
              'Elements will be saved inside  <parent folder> / <subfolder>',
          child: TextField(
            controller: _subfolderCtrl,
            style: AppTheme.bodyMedium,
            onChanged: (_) => setState(() {}), // refresh preview
            decoration: InputDecoration(
              hintText: 'e.g. sprites_extracted',
              hintStyle: AppTheme.bodySmall,
              filled: true,
              fillColor: AppTheme.surfacePanelBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              suffixIcon: _subfolderCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      tooltip: 'Clear (use parent folder directly)',
                      onPressed: () {
                        _subfolderCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // ── Resolved path preview ─────────────────────────────────
        if (_baseFolder.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 2),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 14, color: AppTheme.accentSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _resolvedOutputFolder,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.accentSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ] else
          const SizedBox(height: 12),

        // ── Naming scheme ─────────────────────────────────────────
        _ConfigRow(
          label: 'File naming',
          child: DropdownButtonFormField<String>(
            initialValue: _namingScheme,
            dropdownColor: AppTheme.surfaceCard,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfacePanelBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              if (v != null) setState(() => _namingScheme = v);
            },
          ),
        ),
        const SizedBox(height: 24),

        // ── Export button ─────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.upload_outlined),
            label: Text(
              _exportSelectedOnly && selectedCount > 0
                  ? 'Export $selectedCount elements'
                  : 'Export all $totalCount elements',
            ),
            onPressed: _baseFolder.isEmpty ? null : () => _runExport(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryButton,
              foregroundColor: AppTheme.buttonText,
            ),
          ),
        ),
      ],
    );
  }

  // ── State screens ─────────────────────────────────────────────

  Widget _exportingState(ExportService svc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppProgressIndicator(
        step: svc.progressStep,
        progress: svc.progress,
      ),
    );
  }

  Widget _doneState(ExportService svc) {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline,
            size: 56, color: AppTheme.success),
        const SizedBox(height: 12),
        Text('${svc.exportedCount} files exported!',
            style: AppTheme.headlineMedium),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_outlined,
                size: 14, color: AppTheme.accentSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _resolvedOutputFolder,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.accentSecondary),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
              OutlinedButton.icon(
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open Folder'),
                onPressed: () => _openFolder(_resolvedOutputFolder),
              ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                context.read<ExportService>().reset();
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _errorState(ExportService svc) {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
        const SizedBox(height: 12),
        Text('Export failed', style: AppTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(svc.errorMessage ?? '',
            style: AppTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                context.read<ExportService>().reset();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _runExport(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Future<void> _runExport(BuildContext context) async {
    if (_baseFolder.isEmpty) return;

    final outputFolder = _resolvedOutputFolder;
    await FileUtils.ensureDir(outputFolder);

    final workspace = context.read<WorkspaceProvider>();
    final result = workspace.result;
    if (result == null) return;

    final options = workspace.buildExportOptions(
      outputFolder: outputFolder,
      namingScheme: _namingScheme,
      exportSelectedOnly: _exportSelectedOnly,
    );

    await context.read<ExportService>().export(
          result: result,
          options: options,
        );
  }

  void _openFolder(String path) {
    try {
      if (Platform.isLinux) {
        Process.start('xdg-open', [path]);
      } else if (Platform.isWindows) {
        Process.start('explorer', [path]);
      } else if (Platform.isMacOS) {
        Process.start('open', [path]);
      }
    } catch (_) {}
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  const _ConfigRow({required this.label, this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTheme.labelMedium),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!, style: AppTheme.bodySmall),
        ],
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
