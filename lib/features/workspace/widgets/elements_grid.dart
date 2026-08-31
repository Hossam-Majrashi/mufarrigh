import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../workspace_provider.dart';
import 'element_thumbnail.dart';

/// Scrollable grid of all detected elements.
class ElementsGrid extends StatelessWidget {
  const ElementsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        final elements = provider.elements;

        if (elements.isEmpty) {
          return _emptyState(context);
        }

        return Column(
          children: [
            _toolbar(context, provider),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: elements.length,
                itemBuilder: (ctx, i) {
                  final el = elements[i];
                  final isSelected = provider.selectedElementIndex == i;
                  final isChecked = provider.selectedForExport.contains(i);
                  final bgColor = el.backgroundColorOverride ??
                      provider.globalBackgroundColor;

                  return ElementThumbnail(
                    element: el,
                    index: i,
                    isSelected: isSelected,
                    isChecked: isChecked,
                    previewBackgroundColor: bgColor,
                    onTap: () => provider.selectElement(i),
                    onLongPress: () =>
                        _showContextMenu(context, provider, i),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar(BuildContext context, WorkspaceProvider provider) {
    final total = provider.elements.length;
    final selected = provider.selectedForExport.length;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Text(
            '$total elements',
            style: AppTheme.bodySmall,
          ),
          const Spacer(),
          if (selected > 0) ...[
            Text('$selected selected',
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.accentPrimary)),
            const SizedBox(width: 8),
          ],
          IconButton(
            iconSize: 18,
            tooltip: 'Select all',
            icon: const Icon(Icons.select_all_outlined),
            onPressed: () => provider.selectAllForExport(),
          ),
          IconButton(
            iconSize: 18,
            tooltip: 'Deselect all',
            icon: const Icon(Icons.deselect_outlined),
            onPressed: () => provider.deselectAllForExport(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_outlined,
              size: 48, color: AppTheme.onSurfaceDim),
          const SizedBox(height: 12),
          Text(
            'No elements detected',
            style: AppTheme.bodyMedium
                .copyWith(color: AppTheme.onSurfaceMid),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting detection sensitivity in Settings.',
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showContextMenu(
      BuildContext context, WorkspaceProvider provider, int index) {
    final el = provider.elements[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, provider, index, el.displayName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('Toggle export selection'),
              onTap: () {
                Navigator.pop(context);
                provider.toggleExportSelection(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppTheme.error),
              title: const Text('Delete',
                  style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, provider, index);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WorkspaceProvider provider,
      int index, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Rename Element'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.renameElement(index, ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkspaceProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Delete Element'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error),
            onPressed: () {
              provider.deleteElement(index);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
