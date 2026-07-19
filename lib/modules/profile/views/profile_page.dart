import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
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
        child: Column(
          children: [
            const AppHeader(
              title: 'Profil',
              showAvatar: true,
            ),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: controller.loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileCard(
                            controller.userName.value,
                            controller.userRole.value,
                            controller.userDepartment.value,
                            controller.userId.value,
                            controller.userPhone.value),
                        const SizedBox(height: 20),
                        _buildSettingsCard(),
                        const SizedBox(height: 20),
                        _buildStatsCard(
                            controller.userWorkHours.value,
                            controller.userRating.value),
                        const SizedBox(height: 20),
                        _buildLogoutButton(),
                        const SizedBox(height: 16),
                        _buildVersion(),
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
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XODIM MA\'LUMOTI',
                      style: AppTextStyles.labelCaps(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(name, style: AppTextStyles.h1()),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      role,
                      style: AppTextStyles.labelCaps(
                          color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.badge,
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
                    'Bo\'lim', department, Icons.business_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoColumn(
                    'ID raqam', '#$id', Icons.badge_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(phone,
                  style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant)),
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
              Text(label,
                  style: AppTextStyles.labelCaps(
                      color: AppColors.onSurfaceVariant)),
              Text(value,
                  style: AppTextStyles.bodyMd(), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    final items = [
      {
        'icon': Icons.language,
        'title': 'Tilni o\'zgartirish',
        'subtitle': 'O\'zbekcha',
        'onTap': () => _showLanguagePicker(),
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Maxfiylik',
        'subtitle': 'Xavfsizlik va kirish nazorati',
        'onTap': () {},
      },
      {
        'icon': Icons.help_outline,
        'title': 'Yordam',
        'subtitle': 'Qo\'llab-quvvatlash xizmati',
        'onTap': () {},
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            onTap: item['onTap'] as VoidCallback,
            leading: Icon(item['icon'] as IconData,
                color: AppColors.onSurface, size: 24),
            title: Text(item['title'] as String,
                style: AppTextStyles.bodyLg()),
            subtitle: Text(item['subtitle'] as String,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Til tanlang', style: AppTextStyles.h2()),
            const SizedBox(height: 16),
            ...AppConstants.languages.map((lang) {
              return Obx(
                () => ListTile(
                  leading: Icon(
                    controller.selectedLanguage.value == lang
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  title: Text(lang, style: AppTextStyles.bodyLg()),
                  onTap: () => controller.setLanguage(lang),
                ),
              );
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
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.timer, size: 28, color: AppColors.primary),
                const SizedBox(height: 8),
                Text('$workHours', style: AppTextStyles.h1()),
                Text('Ish soatlari',
                    style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star,
                      size: 28, color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                Text(rating.toString(), style: AppTextStyles.h1()),
                Text('Reyting',
                    style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text('Chiqish',
            style: AppTextStyles.bodyLg(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.errorContainer.withValues(alpha: 0.3),
          side: const BorderSide(color: AppColors.errorContainer),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Center(
      child: Text(
        'Versiya ${AppConstants.appVersion} (Build ${AppConstants.buildNumber})',
        style: AppTextStyles.bodyMd(color: AppColors.outline),
      ),
    );
  }
}
