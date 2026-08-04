import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/translations/app_translations.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(title: 'Profil'.tr, showAvatar: true),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: controller.loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    child: Column(
                      children: [
                        FadeSlideIn(
                          index: 1,
                          child: _buildProfileCard(
                            controller.userName.value,
                            controller.userRole.value,
                            controller.userDepartment.value,
                            controller.userId.value,
                            controller.userPhone.value,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(
                          index: 2,
                          child: _buildStatsCard(
                            controller.userWorkHours.value,
                            controller.userRating.value,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(index: 3, child: _buildSettingsCard()),
                        const SizedBox(height: 20),
                        FadeSlideIn(index: 4, child: _buildLogoutButton()),
                        const SizedBox(height: 16),
                        FadeSlideIn(index: 5, child: _buildVersion()),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    String name,
    String role,
    String department,
    String id,
    String phone,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XODIM MA\'LUMOTI'.tr,
                      style: AppTextStyles.labelCaps(color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(name, style: AppTextStyles.h1()),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: AppShadows.glow(
                          AppColors.primary,
                          alpha: 0.25,
                        ),
                      ),
                      child: Text(
                        role,
                        style: AppTextStyles.labelCaps(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.9,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadows.soft,
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _infoColumn(
                  'Bo\'lim'.tr,
                  department,
                  Icons.business_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoColumn('ID raqam'.tr, '#$id', Icons.badge_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                phone,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelCaps(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMd(),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    final items = [
      (
        icon: Icons.language_rounded,
        title: 'Tilni o\'zgartirish'.tr,
        subtitle: AppTranslations.languageName(
          controller.selectedLanguage.value,
        ),
        onTap: _showLanguagePicker,
      ),
      (
        icon: Icons.lock_outline_rounded,
        title: 'Maxfiylik'.tr,
        subtitle: 'Xavfsizlik va kirish nazorati'.tr,
        onTap: () {},
      ),
      (
        icon: Icons.help_outline_rounded,
        title: 'Yordam'.tr,
        subtitle: 'Qo\'llab-quvvatlash xizmati'.tr,
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 68,
                endIndent: 20,
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ListTile(
              onTap: items[i].onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(items[i].icon, color: AppColors.primary, size: 22),
              ),
              title: Text(items[i].title, style: AppTextStyles.bodyLg()),
              subtitle: Text(
                items[i].subtitle,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outline,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text('Til tanlang'.tr, style: AppTextStyles.h2()),
            const SizedBox(height: 16),
            ...AppConstants.languages.map((lang) {
              return Obx(() {
                final selected = controller.selectedLanguage.value == lang;
                return ListTile(
                  leading: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(selected),
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    '$lang — ${AppTranslations.languageName(lang)}',
                    style: AppTextStyles.bodyLg(),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onTap: () => controller.setLanguage(lang),
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int workHours, double rating) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.timer_rounded,
            iconColor: AppColors.primary,
            value: AnimatedCount(
              value: workHours,
              style: AppTextStyles.display(fontSize: 28),
            ),
            label: 'Ish soatlari'.tr,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.star_rounded,
            iconColor: AppColors.tertiaryContainer,
            value: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rating),
              duration: AppMotion.count,
              curve: AppMotion.emphasized,
              builder: (context, v, child) => Text(
                v.toStringAsFixed(1),
                style: AppTextStyles.display(fontSize: 28),
              ),
            ),
            label: 'Reyting'.tr,
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color iconColor,
    required Widget value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 10),
          value,
          Text(
            label,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Pressable(
      onTap: controller.logout,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.errorContainer),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Hisobdan chiqish'.tr,
              style: AppTextStyles.bodyLg(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Center(
      child: Text(
        '${'Versiya'.tr} ${AppConstants.appVersion} (Build ${AppConstants.buildNumber})',
        style: AppTextStyles.bodyMd(color: AppColors.outline),
      ),
    );
  }
}
