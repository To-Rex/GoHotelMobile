import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../modules/notifications/controllers/notifications_controller.dart';
import '../animations/app_animations.dart';
import '../layout/layout.dart';

/// Navigatsiya aksenti — web frontend bilan bir xil ko'k primary.
const _navigationAccent = AppColors.primary;

/// Xodimlar uchun sokin, "dock" uslubidagi asosiy navigatsiya.
///
/// U ataylab blur va kengayib-torayadigan pill effektidan foydalanmaydi:
/// har bir bo'limning joyi doim bir xil qoladi, shu sababli bir qo'l bilan
/// ishlatish ham, tez ko'z yugurtirish ham oson. Juda tor ekranlarda nomlar
/// yashiriladi, lekin semantic label har doim saqlanadi.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<NavItemData> items;

  /// O'qilmagan bildirishnoma nuqtasi qaysi tabda ko'rsatilsin
  /// (null — hech qaysida).
  final int? badgeIndex;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.items = defaultItems,
    this.badgeIndex = 2,
  }) : assert(items.length > 0, 'At least one navigation item is required.');

  static const defaultItems = [
    NavItemData(Icons.home_outlined, Icons.home_rounded, 'Bosh'),
    NavItemData(
      Icons.assignment_outlined,
      Icons.assignment_rounded,
      'Vazifalar',
    ),
    NavItemData(
      Icons.notifications_outlined,
      Icons.notifications_rounded,
      'Xabarlar',
    ),
    NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final availableWidth = outerConstraints.hasBoundedWidth
            ? outerConstraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final ultraCompact = AppBreakpoints.isUltraCompactWidth(availableWidth);

        return SafeArea(
          minimum: EdgeInsets.fromLTRB(
            ultraCompact ? 4 : 16,
            0,
            ultraCompact ? 4 : 16,
            ultraCompact ? 6 : 12,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _NavigationDock(
                currentIndex: currentIndex,
                onTabChanged: onTabChanged,
                items: items,
                badgeIndex: badgeIndex,
                ultraCompact: ultraCompact,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationDock extends StatelessWidget {
  const _NavigationDock({
    required this.currentIndex,
    required this.onTabChanged,
    required this.items,
    required this.badgeIndex,
    required this.ultraCompact,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<NavItemData> items;
  final int? badgeIndex;
  final bool ultraCompact;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : AppMotion.fast;

    return RepaintBoundary(
      child: Container(
        height: ultraCompact ? 56 : 70,
        padding: EdgeInsets.symmetric(horizontal: ultraCompact ? 3 : 6),
        decoration: BoxDecoration(
          // Oq, matte sirt mazmunli kartalardan alohida ko'rinadi, ammo
          // sahifaning e'tiborini tortib olmaydi.
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(ultraCompact ? 20 : 24),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.48),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 360 px dan boshlab 4 label xotirjam sig'adi. Watch holatida
            // ikonlar 40 px dan kichik bo'lmaydi.
            final showLabels =
                !ultraCompact &&
                items.length <= 4 &&
                constraints.maxWidth >= 300;
            const minItemWidth = 40.0;
            final needsScroll =
                ultraCompact &&
                constraints.maxWidth < items.length * minItemWidth;
            final itemWidth = needsScroll
                ? minItemWidth
                : constraints.maxWidth / items.length;
            final itemsRow = Row(
              children: List.generate(items.length, (index) {
                final child = _DockItem(
                  item: items[index],
                  selected: index == currentIndex,
                  showLabel: needsScroll ? false : showLabels,
                  ultraCompact: needsScroll || ultraCompact,
                  showBadge: index == badgeIndex,
                  duration: duration,
                  onTap: () => _select(index),
                );
                return needsScroll
                    ? SizedBox(width: itemWidth, child: child)
                    : Expanded(child: child);
              }),
            );

            if (!needsScroll) return itemsRow;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: itemsRow,
            );
          },
        ),
      ),
    );
  }

  void _select(int index) {
    HapticFeedback.selectionClick();
    onTabChanged(index);
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.ultraCompact,
    required this.showBadge,
    required this.duration,
    required this.onTap,
  });

  final NavItemData item;
  final bool selected;
  final bool showLabel;
  final bool ultraCompact;
  final bool showBadge;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = item.label.tr;
    final iconSize = ultraCompact ? 21.0 : 22.0;
    final iconButtonSize = ultraCompact ? 36.0 : 38.0;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 650),
        child: Pressable(
          haptic: false,
          pressedScale: 0.96,
          onTap: onTap,
          child: SizedBox.expand(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.emphasized,
                    width: iconButtonSize,
                    height: ultraCompact ? 36 : 34,
                    decoration: BoxDecoration(
                      color: selected
                          ? _navigationAccent.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _DockIcon(
                        item: item,
                        selected: selected,
                        showBadge: showBadge,
                        size: iconSize,
                      ),
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: AppMotion.emphasized,
                      style:
                          AppTextStyles.bodyMd(
                            color: selected
                                ? _navigationAccent
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ).copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.item,
    required this.selected,
    required this.showBadge,
    required this.size,
  });

  final NavItemData item;
  final bool selected;
  final bool showBadge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? item.filled : item.outline,
      size: size,
      color: selected ? _navigationAccent : AppColors.onSurfaceVariant,
    );

    if (!showBadge) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        const Positioned(top: -2, right: -2, child: _UnreadDot()),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationsController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<NotificationsController>();
    return Obx(() {
      if (controller.unreadCount == 0) return const SizedBox.shrink();
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.surfaceContainerLowest,
            width: 1.5,
          ),
        ),
      );
    });
  }
}

class NavItemData {
  final IconData outline;
  final IconData filled;
  final String label;

  const NavItemData(this.outline, this.filled, this.label);
}
