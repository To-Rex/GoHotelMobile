import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/animations/app_animations.dart';

/// Horizontal page gutter for the administration views.
///
/// The smallest tier deliberately starts at 8dp.  At a 180dp-wide wearable
/// window, a conventional 20–24dp mobile gutter leaves too little space for
/// an actionable card or a text field.  Larger layouts retain a relaxed
/// reading measure instead of stretching content edge-to-edge.
double adminPageGutterForWidth(double width) {
  if (width < 240) return 8;
  if (width < 600) return 16;
  if (width < 840) return 24;
  return 32;
}

/// Keeps an admin section centered and readable on wide desktop windows.
///
/// This widget intentionally measures its parent rather than the entire
/// screen: an expanded admin navigation rail reduces the available width for
/// the page body, and the body must still adapt correctly in that situation.
class AdminContentConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AdminContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = 1160,
  }) : assert(maxWidth > 0);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Boshqaruv sahifalaridagi funksional blok uchun yengil, tekis sirt.
///
/// Bu kartochka emas, balki bir-biriga bog'liq ma'lumot yoki amallarni
/// guruhlaydigan workspace konteyneri. Shuning uchun soya ishlatilmaydi va
/// watch kengligida ichki bo'shliq avtomatik qisqaradi.
class AdminWorkspaceSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;

  const AdminWorkspaceSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dense = constraints.maxWidth < 260;
        return Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(dense ? 12 : 16),
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(dense ? radius - 2 : radius),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Xona holati uchun rang — WEB xonalar sahifasi bilan aynan bir xil:
/// bo'sh yashil, band qizil, band qilingan ko'k, tozalash sariq...
Color roomStatusColor(String status) {
  switch (status) {
    case 'AVAILABLE':
      return AppColors.statusAvailable;
    case 'OCCUPIED':
      return AppColors.statusOccupied;
    case 'RESERVED':
      return AppColors.statusReserved;
    case 'CLEANING':
      return AppColors.statusCleaningRoom;
    case 'MAINTENANCE':
      return AppColors.statusMaintenance;
    case 'INSPECTION':
      return AppColors.statusInspection;
    case 'OUT_OF_SERVICE':
      return AppColors.statusOutOfService;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Vazifa holati rangi — web xo'jalik sahifasi bilan bir xil
/// (ochiq binafsha, jarayonda ko'k, yakunlangan yashil).
Color taskStatusColor(String status) {
  switch (status) {
    case 'OPEN':
      return AppColors.statusViolet;
    case 'IN_PROGRESS':
      return AppColors.statusReserved;
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
      return AppColors.statusReserved;
    case 'HIGH':
      return AppColors.statusInProgress;
    case 'URGENT':
      return AppColors.error;
    default:
      return AppColors.onSurfaceVariant;
  }
}

/// Bron holati rangi — web bandlov belgilari bilan bir xil
/// (kutilmoqda binafsha, tasdiqlangan ko'k, yashamoqda yashil).
Color reservationStatusColor(String status) {
  switch (status) {
    case 'PENDING':
      return AppColors.statusViolet;
    case 'CONFIRMED':
      return AppColors.statusReserved;
    case 'CHECKED_IN':
      return AppColors.statusAvailable;
    case 'CHECKED_OUT':
      return AppColors.statusPending;
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
                    // A fraction of the available line is safer than a
                    // fixed 140dp block on a watch-width loading state.
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      alignment: Alignment.centerLeft,
                      child: _block(double.infinity, 10),
                    ),
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
