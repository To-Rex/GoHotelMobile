import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showAvatar;
  final List<Widget>? actions;
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, size: 24, color: AppColors.onSurface),
              ),
            ),
          if (showAvatar)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.person, color: AppColors.onPrimary, size: 24),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h1()),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}
