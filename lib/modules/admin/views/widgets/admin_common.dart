import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/animations/app_animations.dart';

/// Xona holati uchun rang (dashboard, xonalar sahifasi va chiplar uchun).
Color roomStatusColor(String status) {
  switch (status) {
    case 'AVAILABLE':
      return AppColors.success;
    case 'OCCUPIED':
      return AppColors.primary;
    case 'RESERVED':
      return AppColors.secondaryContainer;
    case 'CLEANING':
      return AppColors.statusInProgress;
    case 'MAINTENANCE':
      return AppColors.tertiaryContainer;
    case 'INSPECTION':
      return AppColors.outline;
    case 'OUT_OF_SERVICE':
      return AppColors.error;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Vazifa holati rangi.
Color taskStatusColor(String status) {
  switch (status) {
    case 'OPEN':
      return AppColors.statusPending;
    case 'IN_PROGRESS':
      return AppColors.statusInProgress;
    case 'COMPLETED':
      return AppColors.statusCleaned;
    case 'CANCELLED':
      return AppColors.error;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Muhimlik darajasi rangi.
Color priorityColor(String priority) {
  switch (priority) {
    case 'LOW':
      return AppColors.outline;
    case 'MEDIUM':
      return AppColors.secondary;
    case 'HIGH':
      return AppColors.statusInProgress;
    case 'URGENT':
      return AppColors.error;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Bron holati rangi.
Color reservationStatusColor(String status) {
  switch (status) {
    case 'PENDING':
      return AppColors.statusPending;
    case 'CONFIRMED':
      return AppColors.secondary;
    case 'CHECKED_IN':
      return AppColors.primary;
    case 'CHECKED_OUT':
      return AppColors.statusCleaned;
    case 'CANCELLED':
    case 'NO_SHOW':
      return AppColors.error;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Muammo holati rangi.
Color problemStatusColor(String status) {
  switch (status) {
    case 'OPEN':
      return AppColors.error;
    case 'IN_PROGRESS':
      return AppColors.statusInProgress;
    case 'RESOLVED':
      return AppColors.statusCleaned;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// 1250000 → "1 250 000" (so'm ko'rsatkichlari uchun).
String formatMoney(double value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer(negative ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Kichik rangli belgi-chip (dizayn tili: 999px radius, 10% fon).
class AdminChip extends StatelessWidget {
  final String label;
  final Color color;

  const AdminChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label, style: AppTextStyles.labelCaps(color: color)),
    );
  }
}

/// Yuklanish uchun pulsatsiyalanuvchi skelet kartochkalar —
/// aylanuvchi indikator o'rniga zamonaviy, sokin ko'rinish.
class AdminSkeletonList extends StatefulWidget {
  final int count;
  final double height;

  const AdminSkeletonList({super.key, this.count = 4, this.height = 92});

  @override
  State<AdminSkeletonList> createState() => _AdminSkeletonListState();
}

class _AdminSkeletonListState extends State<AdminSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: List.generate(widget.count, (i) {
        return Container(
          height: widget.height,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              _block(44, 44, circle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(double.infinity, 12),
                    const SizedBox(height: 8),
                    _block(140, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
    if (MediaQuery.of(context).disableAnimations) return content;
    return FadeTransition(
      opacity: Tween(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: content,
    );
  }

  Widget _block(double width, double height, {bool circle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(circle ? 999 : 6),
      ),
    );
  }
}

/// Sanalib chiqadigan pul qiymati (moliya ko'rsatkichlari uchun).
class AnimatedMoney extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;

  const AnimatedMoney({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: AppMotion.count,
      curve: AppMotion.emphasized,
      builder: (context, v, child) => Text(
        '$prefix${formatMoney(v)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}
