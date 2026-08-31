import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_utils.dart';
import '../home/recent_projects_provider.dart';
import '../settings/settings_provider.dart';
import '../workspace/workspace_provider.dart';
import '../workspace/workspace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDragging = false;

  Future<void> _importImage(BuildContext context,
      {Uint8List? bytes, String? path}) async {
    Uint8List? imageBytes = bytes;
    String? imagePath = path;

    if (imageBytes == null) {
      final picked = await FileUtils.pickImageFile();
      if (picked == null) return;
      imageBytes = picked.bytes;
      imagePath = picked.path;
    }

    if (!context.mounted) return;

    // Initialize workspace & navigate
    final workspace = context.read<WorkspaceProvider>();
    final settings = context.read<SettingsProvider>();
    final recent = context.read<RecentProjectsProvider>();

    workspace.reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkspaceScreen()),
    );

    // Start processing (non-blocking — workspace shows progress UI)
    workspace.loadImage(
      imageBytes,
      imagePath ?? '',
      settings.processingOptions,
    ).then((_) {
      if (workspace.state == ProcessingState.done && imagePath != null) {
        recent.add(
          imagePath: imagePath,
          elementCount: workspace.elements.length,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: DropTarget(
        onDragDone: (details) async {
          setState(() => _isDragging = false);
          final files = details.files;
          if (files.isEmpty) return;
          final file = files.first;
          final bytes = await file.readAsBytes();
          if (mounted) {
            _importImage(context, bytes: Uint8List.fromList(bytes),
                path: file.path);
          }
        },
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        child: CustomScrollView(
          slivers: [
            _buildHeroHeader(context),
            _buildImportCard(context),
            _buildRecentProjects(context),
            const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.primaryDeep,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App label
                  Text(
                    'مُفرِّغ',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.8),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Arabic name
                  ShaderMask(
                    shaderCallback: (rect) =>
                        AppTheme.accentGradient.createShader(rect),
                    child: const Text(
                      'مُفرِّغ',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Sprite Sheet Extractor',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onSurfaceMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImportCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isDragging
                  ? AppTheme.accentPrimary
                  : AppTheme.divider,
              width: _isDragging ? 2 : 1,
            ),
            gradient: _isDragging
                ? LinearGradient(colors: [
                    AppTheme.accentPrimary.withValues(alpha: 0.08),
                    AppTheme.selectedBg.withValues(alpha: 0.2),
                  ])
                : AppTheme.cardGradient,
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Drop zone icon
              AnimatedScale(
                scale: _isDragging ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentPrimary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.upload_file_outlined,
                    size: 36,
                    color: AppTheme.accentPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isDragging ? 'Release to import' : 'Drop image here',
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'or browse files (PNG, JPG, WebP)',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('New Sprite Sheet'),
                onPressed: () => _importImage(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProjects(BuildContext context) {
    return Consumer<RecentProjectsProvider>(
      builder: (context, recent, _) {
        final projects = recent.projects;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Recent Projects', style: AppTheme.titleMedium),
                    const Spacer(),
                    if (projects.isNotEmpty)
                      TextButton(
                        onPressed: () => _confirmClearHistory(context, recent),
                        child: Text(
                          'Clear',
                          style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.onSurfaceDim),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (projects.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.history_outlined,
                              size: 36, color: AppTheme.onSurfaceDim),
                          const SizedBox(height: 8),
                          Text(
                            'No recent projects yet.\nImport a sprite sheet to get started.',
                            style: AppTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...projects.map((p) => _RecentProjectCard(
                        project: p,
                        onTap: () => _importImage(context, path: p.imagePath),
                        onRemove: () => recent.remove(p.imagePath),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearHistory(
      BuildContext context, RecentProjectsProvider recent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Clear History?'),
        content: const Text('Remove all recent projects?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white),
            onPressed: () {
              recent.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _RecentProjectCard extends StatelessWidget {
  final dynamic project;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentProjectCard({
    required this.project,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.selectedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grid_view_outlined,
                    color: AppTheme.accentPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: AppTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      '${project.elementCount} elements · ${_relativeTime(project.openedAt)}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: AppTheme.onSurfaceDim),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
