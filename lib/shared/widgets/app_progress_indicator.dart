import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated progress indicator for long-running operations.
class AppProgressIndicator extends StatefulWidget {
  final String step;
  final double progress;

  const AppProgressIndicator({
    super.key,
    required this.step,
    required this.progress,
  });

  @override
  State<AppProgressIndicator> createState() => _AppProgressIndicatorState();
}

class _AppProgressIndicatorState extends State<AppProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentPrimary
                        .withValues(alpha: 0.2 + 0.3 * _pulseAnim.value),
                    AppTheme.accentPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: widget.progress > 0 && widget.progress < 1
                        ? widget.progress
                        : null,
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation(
                        AppTheme.accentPrimary),
                    backgroundColor: AppTheme.divider,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.step,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.onSurfaceMid,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.progress > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: AppTheme.divider,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentPrimary),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
