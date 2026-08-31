import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_progress_indicator.dart';
import '../export/export_dialog.dart';
import '../settings/settings_provider.dart';
import 'widgets/elements_grid.dart';
import 'widgets/properties_panel.dart';
import 'widgets/sheet_overlay_view.dart';
import 'workspace_provider.dart';

/// Adaptive workspace screen.
///
/// - Desktop / tablet (≥ 720 dp): 3-pane horizontal layout
/// - Mobile (< 720 dp): TabBar with 3 tabs
class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 720;
    return isDesktop
        ? const _DesktopWorkspace()
        : const _MobileWorkspace();
  }
}

// ──────────────────────────────────────────────────────────────
// Desktop 3-pane layout
// ──────────────────────────────────────────────────────────────

class _DesktopWorkspace extends StatelessWidget {
  const _DesktopWorkspace();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfacePanelBg,
      appBar: _WorkspaceAppBar(isDesktop: true),
      body: Consumer<WorkspaceProvider>(
        builder: (context, provider, _) {
          if (provider.isProcessing) {
            return Center(
              child: AppProgressIndicator(
                step: provider.processingStep,
                progress: provider.processingProgress,
              ),
            );
          }
          if (provider.state == ProcessingState.error) {
            return _ErrorState(message: provider.errorMessage ?? 'Unknown error');
          }
          return Row(
            children: [
              // Left pane — Sheet viewer
              Expanded(
                flex: 5,
                child: _Pane(
                  title: 'Original Sheet',
                  child: const SheetOverlayView(),
                ),
              ),
              const _VerticalDivider(),

              // Center pane — Elements grid
              SizedBox(
                width: 320,
                child: _Pane(
                  title: 'Elements (${provider.elements.length})',
                  child: const ElementsGrid(),
                ),
              ),
              const _VerticalDivider(),

              // Right pane — Properties
              SizedBox(
                width: 280,
                child: _Pane(
                  title: 'Properties',
                  child: const PropertiesPanel(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Mobile tabbed layout
// ──────────────────────────────────────────────────────────────

class _MobileWorkspace extends StatefulWidget {
  const _MobileWorkspace();

  @override
  State<_MobileWorkspace> createState() => _MobileWorkspaceState();
}

class _MobileWorkspaceState extends State<_MobileWorkspace>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _WorkspaceAppBar(
        isDesktop: false,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.accentPrimary,
          unselectedLabelColor: AppTheme.onSurfaceDim,
          indicatorColor: AppTheme.accentPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(icon: Icon(Icons.image_outlined), text: 'Sheet'),
            Tab(icon: Icon(Icons.grid_view_outlined), text: 'Elements'),
            Tab(icon: Icon(Icons.tune_outlined), text: 'Properties'),
          ],
        ),
      ),
      body: Consumer<WorkspaceProvider>(
        builder: (context, provider, _) {
          if (provider.isProcessing) {
            return Center(
              child: AppProgressIndicator(
                step: provider.processingStep,
                progress: provider.processingProgress,
              ),
            );
          }
          if (provider.state == ProcessingState.error) {
            return _ErrorState(
                message: provider.errorMessage ?? 'Unknown error');
          }
          return TabBarView(
            controller: _tabCtrl,
            children: const [
              SheetOverlayView(),
              ElementsGrid(),
              PropertiesPanel(),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared components
// ──────────────────────────────────────────────────────────────

class _WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final PreferredSizeWidget? bottom;

  const _WorkspaceAppBar({required this.isDesktop, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        final selected = provider.selectedForExport.length;
        return AppBar(
          backgroundColor: AppTheme.primaryDeep,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Workspace', style: AppTheme.titleMedium),
              if (provider.hasResult)
                Text(
                  '${provider.elements.length} elements',
                  style: AppTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            if (provider.hasResult) ...[
              // Reprocess
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                tooltip: 'Re-process',
                onPressed: () => _reprocess(context, provider),
              ),
              // Export
              TextButton.icon(
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Text(
                  selected > 0
                      ? 'Export ($selected)'
                      : 'Export All',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentPrimary,
                ),
                onPressed: () => _showExport(context, provider),
              ),
            ],
            const SizedBox(width: 8),
          ],
          bottom: bottom,
        );
      },
    );
  }

  Future<void> _reprocess(
      BuildContext context, WorkspaceProvider provider) async {
    final settings = context.read<SettingsProvider>();
    await provider.reprocess(settings.processingOptions);
  }

  void _showExport(BuildContext context, WorkspaceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExportDialog(),
    );
  }
}

class _Pane extends StatelessWidget {
  final String title;
  final Widget child;

  const _Pane({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: AppTheme.primaryDeep,
            border: Border(bottom: BorderSide(color: AppTheme.divider)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(title, style: AppTheme.bodySmall),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: AppTheme.divider,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('Processing Failed',
                style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Try Again'),
              onPressed: () {
                final provider = context.read<WorkspaceProvider>();
                final settings = context.read<SettingsProvider>();
                provider.reprocess(settings.processingOptions);
              },
            ),
          ],
        ),
      ),
    );
  }
}
