import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../modules/notifications/controllers/notifications_controller.dart';
import '../animations/app_animations.dart';

/// Suzuvchi shisha "pill" navigatsiya: faol tab kengayib, nomi ochiladi.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  static const _navItems = [
    _NavItemData(Icons.home_outlined, Icons.home_rounded, 'Bosh'),
    _NavItemData(Icons.assignment_outlined, Icons.assignment_rounded, 'Vazifalar'),
    _NavItemData(Icons.notifications_outlined, Icons.notifications_rounded, 'Xabarlar'),
    _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: AppShadows.raised,
            ),
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = i == currentIndex;
                return Expanded(
                  flex: selected ? 5 : 3,
                  child: _NavButton(
                    item: item,
                    selected: selected,
                    showBadge: i == 2,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTabChanged(i);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItemData item;
  final bool selected;
  final bool showBadge;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.showBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.emphasized,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              Flexible(
                child: AnimatedSize(
                  duration: AppMotion.base,
                  curve: AppMotion.emphasized,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: AppTextStyles.statusBadge(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon = AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Icon(
        selected ? item.filled : item.outline,
        key: ValueKey(selected),
        size: 24,
        color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );

    if (!showBadge) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -2,
          right: -2,
          child: _UnreadDot(),
        ),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationsController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<NotificationsController>();
    return Obx(() {
      if (controller.unreadCount == 0) return const SizedBox.shrink();
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceContainerLowest, width: 1.5),
        ),
      );
    });
  }
}

class _NavItemData {
  final IconData outline;
  final IconData filled;
  final String label;

  const _NavItemData(this.outline, this.filled, this.label);
}
