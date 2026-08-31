import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/checkerboard_background.dart';
import '../../../shared/widgets/color_picker_button.dart';
import '../../settings/settings_provider.dart';
import '../workspace_provider.dart';

/// Properties panel showing details and controls for the selected element.
class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, _) {
        if (!provider.hasResult) return _placeholder();
        if (provider.selectedElement == null) return _noSelection(provider);
        return _elementDetails(context, provider);
      },
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Text('Import a sheet to begin.',
          style: AppTheme.bodySmall),
    );
  }

  Widget _noSelection(WorkspaceProvider provider) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Global Background'),
              const SizedBox(height: 8),
              ColorPickerButton(
                color: provider.globalBackgroundColor,
                label: 'Global Background',
                onColorChanged: (c) => provider.setGlobalBackground(c),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    Icon(Icons.touch_app_outlined,
                        color: AppTheme.onSurfaceDim, size: 32),
                    const SizedBox(height: 8),
                    Text('Tap an element to select it',
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${provider.elements.length} elements detected',
                style: AppTheme.bodySmall,
              ),

              // ── Detection Settings ──────────────────────────
              const SizedBox(height: 24),
              _sectionHeader('Detection'),
              const SizedBox(height: 8),

              _CompactSlider(
                label: 'Sensitivity',
                value: settings.processingOptions.backgroundTolerance
                    .toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                onChanged: (v) =>
                    settings.setBackgroundTolerance(v.round()),
              ),
              _CompactSlider(
                label: 'Min Element Size',
                value: settings.processingOptions.minElementSize
                    .toDouble(),
                min: 10,
                max: 2000,
                divisions: 40,
                onChanged: (v) =>
                    settings.setMinElementSize(v.round()),
              ),
              _CompactSlider(
                label: 'Gap Erosion',
                value: settings.processingOptions.erosionAmount
                    .toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (v) =>
                    settings.setErosionAmount(v.round()),
              ),
              _CompactSlider(
                label: 'Edge Feathering',
                value: settings.processingOptions.featheringRadius
                    .toDouble(),
                min: 0,
                max: 4,
                divisions: 4,
                onChanged: (v) =>
                    settings.setFeatheringRadius(v.round()),
              ),
              _CompactSlider(
                label: 'Element Padding',
                value: settings.processingOptions.elementPadding
                    .toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                onChanged: (v) =>
                    settings.setElementPadding(v.round()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_outlined, size: 16),
                  label: const Text('Re-detect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryButton,
                    foregroundColor: AppTheme.buttonText,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    provider.reprocess(
                        settings.processingOptions);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _elementDetails(BuildContext context, WorkspaceProvider provider) {
    final el = provider.selectedElement!;
    final idx = provider.selectedElementIndex!;
    final effectiveBg =
        el.backgroundColorOverride ?? provider.globalBackgroundColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              clipBehavior: Clip.antiAlias,
              child: effectiveBg != null
                  ? ColoredBox(
                      color: effectiveBg,
                      child: _image(el.cropBytes),
                    )
                  : CheckerboardBackground(
                      child: _image(el.cropBytes),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          _sectionHeader('Name'),
          const SizedBox(height: 6),
          _EditableNameRow(
            name: el.displayName,
            onSave: (name) => provider.renameElement(idx, name),
          ),
          const SizedBox(height: 16),

          // Bounds
          _sectionHeader('Bounding Box'),
          const SizedBox(height: 6),
          _infoGrid([
            ('X', '${el.x} px'),
            ('Y', '${el.y} px'),
            ('W', '${el.width} px'),
            ('H', '${el.height} px'),
          ]),
          const SizedBox(height: 16),

          // Per-element background
          _sectionHeader('Background Override'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ColorPickerButton(
                  color: el.backgroundColorOverride,
                  label: 'Element Background',
                  onColorChanged: (c) =>
                      provider.setElementBackgroundOverride(idx, c),
                ),
              ),
              if (el.hasColorOverride) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear override (use global)',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () =>
                      provider.setElementBackgroundOverride(idx, null),
                ),
              ],
            ],
          ),
          if (!el.hasColorOverride)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Using global setting',
                style: AppTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 24),

          // Actions
          _sectionHeader('Actions'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.check_box_outlined, size: 16),
                  label: const Text('Select'),
                  onPressed: () => provider.toggleExportSelection(idx),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  onPressed: () => _confirmDelete(context, provider, idx),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _image(List<int> bytes) {
    return Image.memory(
      bytes as dynamic,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTheme.labelMedium,
    );
  }

  Widget _infoGrid(List<(String, String)> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((pair) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfacePanelBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pair.$1,
                        style: AppTheme.labelMedium),
                    const SizedBox(width: 6),
                    Text(pair.$2, style: AppTheme.bodySmall),
                  ],
                ),
              ))
          .toList(),
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

class _EditableNameRow extends StatefulWidget {
  final String name;
  final ValueChanged<String> onSave;
  const _EditableNameRow({required this.name, required this.onSave});

  @override
  State<_EditableNameRow> createState() => _EditableNameRowState();
}

class _EditableNameRowState extends State<_EditableNameRow> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(_EditableNameRow old) {
    super.didUpdateWidget(old);
    if (!_editing && old.name != widget.name) {
      _ctrl.text = widget.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.accentPrimary),
            onPressed: () {
              setState(() => _editing = false);
              widget.onSave(_ctrl.text.trim());
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.onSurfaceDim),
            onPressed: () {
              setState(() => _editing = false);
              _ctrl.text = widget.name;
            },
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfacePanelBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(widget.name, style: AppTheme.bodyMedium),
            ),
            const Icon(Icons.edit_outlined,
                size: 16, color: AppTheme.onSurfaceDim),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Compact slider for narrow Properties panel
// ──────────────────────────────────────────────────────────────

class _CompactSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceMid)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value.round().toString(),
                  style: AppTheme.bodySmall
                      .copyWith(color: AppTheme.accentPrimary, fontSize: 11),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
