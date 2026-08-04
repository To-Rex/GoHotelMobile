import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../animations/app_animations.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _float,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).disableAnimations
                        ? 0
                        : -6 * Curves.easeInOut.transform(_float.value),
                  ),
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surfaceContainer,
                        AppColors.surfaceContainerLow,
                      ],
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 44,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.message,
                style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (widget.actionLabel != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onAction,
                  child: Text(widget.actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
