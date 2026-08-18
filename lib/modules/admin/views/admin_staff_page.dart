import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/staff_model.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_staff_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminStaffPage extends GetView<AdminStaffController> {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final main = Get.find<AdminMainController>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Xodimlar'.tr,
              subtitle: 'Jamoani boshqarish'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
              actions: [
                if (main.can('employee.create'))
                  Pressable(
                    onTap: () => Get.toNamed('/admin-staff-form'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryContainer,
                            AppColors.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.glow(
                          AppColors.primary,
                          alpha: 0.25,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_rounded,
                        color: AppColors.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Obx(() => _buildContent(main)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AdminMainController main) {
    if (controller.isLoading.value && controller.staff.isEmpty) {
      return const AdminSkeletonList(count: 6, height: 84);
    }

    if (controller.staff.isEmpty) {
      // Tarmoq xatosi bo'sh ro'yxatdan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: error == null ? Icons.groups_outlined : Icons.wifi_off_rounded,
          message: error ?? 'Xodimlar topilmadi'.tr,
          actionLabel: error == null ? null : 'Qayta urinish'.tr,
          onAction: error == null ? null : controller.loadData,
        ),
      );
    }

    final canEdit = main.can('employee.update');
    return Column(
      children: controller.staff
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideIn(
              index: entry.key.clamp(0, 12),
              child: _buildStaffCard(entry.value, canEdit),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStaffCard(StaffModel staff, bool canEdit) {
    final active = staff.status == 'ACTIVE';
    final color = active ? AppColors.statusCleaned : AppColors.outline;
    return Pressable(
      onTap: canEdit
          ? () => Get.toNamed('/admin-staff-form', arguments: staff)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLg(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      '@${staff.username}',
                      if (staff.phone?.isNotEmpty == true) staff.phone!,
                    ].join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AdminChip(label: active ? 'Faol'.tr : 'Faol emas'.tr, color: color),
            if (canEdit) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
            ],
          ],
        ),
      ),
    );
  }
}
