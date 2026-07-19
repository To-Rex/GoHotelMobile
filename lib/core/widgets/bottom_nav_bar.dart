import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  static const _navItems = [
    _NavItemData(Icons.home_outlined, Icons.home, 'Bosh'),
    _NavItemData(Icons.assignment_outlined, Icons.assignment, 'Vazifalar'),
    _NavItemData(Icons.notifications_outlined, Icons.notifications, 'Xabarlar'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedLabelStyle: AppTextStyles.labelCaps(fontSize: 10),
          unselectedLabelStyle:
              AppTextStyles.labelCaps(fontSize: 10, color: AppColors.onSurfaceVariant),
          items: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isSelected = i == currentIndex;
            return BottomNavigationBarItem(
              icon: Icon(isSelected ? item.filled : item.outline, size: 24),
              label: item.label,
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData outline;
  final IconData filled;
  final String label;

  const _NavItemData(this.outline, this.filled, this.label);
}
