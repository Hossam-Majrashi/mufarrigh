import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../core/theme/app_theme.dart';

/// A button that shows the current color and opens a color picker dialog.
class ColorPickerButton extends StatelessWidget {
  final Color? color; // null = transparent
  final ValueChanged<Color?> onColorChanged;
  final String label;
  final bool showTransparentOption;

  const ColorPickerButton({
    super.key,
    required this.color,
    required this.onColorChanged,
    required this.label,
    this.showTransparentOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTransparent = color == null;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            // Color swatch
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.divider),
              ),
              child: isTransparent
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomPaint(
                        painter: _SmallCheckerPainter(),
                        child: const SizedBox(width: 28, height: 28),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: ColoredBox(color: color!),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isTransparent
                    ? 'Transparent'
                    : '#${color!.value.toRadixString(16).substring(2).toUpperCase()}',
                style: AppTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.expand_more, color: AppTheme.onSurfaceMid,
                size: 20),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    Color current = color ?? Colors.white;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label, style: AppTheme.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTransparentOption) ...[
                Row(
                  children: [
                    const Icon(Icons.format_color_reset_outlined,
                        color: AppTheme.onSurfaceMid, size: 18),
                    const SizedBox(width: 8),
                    Text('Transparent',
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.onSurfaceMid)),
                    const Spacer(),
                    Switch(
                      value: color == null,
                      onChanged: (v) {
                        Navigator.pop(ctx);
                        onColorChanged(v ? null : current);
                      },
                    ),
                  ],
                ),
                const Divider(),
              ],
              ColorPicker(
                pickerColor: current,
                onColorChanged: (c) => current = c,
                enableAlpha: false,
                labelTypes: const [],
                pickerAreaHeightPercent: 0.8,
              ),
              // Hex input row
              _HexInput(
                color: current,
                onChanged: (c) => current = c,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onColorChanged(current);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _HexInput extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;
  const _HexInput({required this.color, required this.onChanged});

  @override
  State<_HexInput> createState() => _HexInputState();
}

class _HexInputState extends State<_HexInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.color.value.toRadixString(16).substring(2).toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      decoration: InputDecoration(
        prefixText: '#',
        labelText: 'Hex',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLength: 6,
      onSubmitted: (v) {
        try {
          final val = int.parse(v.padLeft(6, '0'), radix: 16);
          widget.onChanged(Color(0xFF000000 | val));
        } catch (_) {}
      },
    );
  }
}

class _SmallCheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 4.0;
    final light = Paint()..color = const Color(0xFF888888);
    final dark = Paint()..color = const Color(0xFF555555);
    final cols = (size.width / cellSize).ceil();
    final rows = (size.height / cellSize).ceil();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
          (r + c) % 2 == 0 ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SmallCheckerPainter _) => false;
}
