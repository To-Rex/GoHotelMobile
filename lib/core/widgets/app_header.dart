import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../animations/app_animations.dart';

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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        12,
      ),
      child: FadeSlideIn(
        child: Row(
          children: [
            if (showBackButton)
              Pressable(
                onTap: () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.soft,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 22, color: AppColors.onSurface),
                ),
              ),
            if (showAvatar)
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryContainer, AppColors.primary],
                  ),
                  boxShadow: AppShadows.glow(AppColors.primary, alpha: 0.25),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.onPrimary, size: 24),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h1(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodyMd(
                          color: AppColors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ...?actions,
          ],
        ),
      ),
    );
  }
}
