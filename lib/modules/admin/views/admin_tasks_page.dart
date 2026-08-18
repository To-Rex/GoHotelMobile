import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/hk_task_model.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_tasks_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminTasksPage extends GetView<AdminTasksController> {
  const AdminTasksPage({super.key});

  static const _filters = [
    ('', 'Hammasi'),
    ('OPEN', 'Ochiq'),
    ('IN_PROGRESS', 'Jarayonda'),
    ('COMPLETED', 'Yakunlangan'),
    ('CANCELLED', 'Bekor qilingan'),
  ];

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
              title: 'Vazifalar boshqaruvi'.tr,
              subtitle: 'Barcha housekeeping vazifalari'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
              actions: [
                if (main.can('housekeeping.task.create'))
                  Pressable(
                    onTap: () => Get.toNamed('/admin-task-form'),
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
                        Icons.add_rounded,
                        color: AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildFilterChips()),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTasks,
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        // Obx sinxron o'qishi uchun qiymat builder boshida olinadi —
        // itemBuilder kechiktirilib chaqiriladi.
        final selected = controller.selectedStatus.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final (value, label) = _filters[index];
            final active = selected == value;
            return Pressable(
              onTap: () => controller.changeFilter(value),
              child: AnimatedContainer(
                duration: AppMotion.base,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  label.tr,
                  style: AppTextStyles.statusBadge(
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildContent(AdminMainController main) {
    if (controller.isLoading.value && controller.tasks.isEmpty) {
      return const AdminSkeletonList(count: 5, height: 120);
    }

    if (controller.tasks.isEmpty) {
      // Tarmoq xatosi bo'sh ro'yxatdan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: error == null
              ? Icons.assignment_outlined
              : Icons.wifi_off_rounded,
          message: error ?? 'Hozircha vazifalar yo\'q'.tr,
          actionLabel: error == null ? null : 'Qayta urinish'.tr,
          onAction: error == null ? null : controller.loadTasks,
        ),
      );
    }

    return Column(
      children: controller.tasks
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideIn(
              // Stagger 12 da to'xtaydi — uzun ro'yxat "bo'sh" ko'rinmasin
              index: entry.key.clamp(0, 12),
              child: _TaskCard(
                task: entry.value,
                canUpdate: main.can('housekeeping.task.update'),
                canAssign: main.can('housekeeping.task.assign'),
                onStart: () =>
                    controller.changeStatus(entry.value, 'IN_PROGRESS'),
                onComplete: () =>
                    controller.changeStatus(entry.value, 'COMPLETED'),
                onCancel: () => _confirmCancel(entry.value),
                onAssign: () => _showAssignSheet(entry.value),
              ),
            ),
          )
          .toList(),
    );
  }

  void _confirmCancel(HkTaskModel task) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Vazifani bekor qilish?'.tr, style: AppTextStyles.h2()),
        content: Text(
          '${'Xona'.tr} ${task.roomNumber} • '
          '${HkTaskModel.typeLabel(task.taskType)}',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Yo\'q'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.changeStatus(task, 'CANCELLED');
            },
            child: Text(
              'Ha, bekor qilish'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignSheet(HkTaskModel task) {
    // isScrollControlled — balandlik cheklovi to'liq amal qilsin (aks holda
    // sheet 9/16 ga qisilib, ro'yxat juda kichrayib qolardi)
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text('Xodimni tanlang'.tr, style: AppTextStyles.h2()),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                if (controller.employees.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Xodimlar topilmadi'.tr,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: controller.employees
                      .map(
                        (staff) => ListTile(
                          leading: Icon(
                            staff.id == task.assignedTo
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            staff.name,
                            style: AppTextStyles.bodyLg(),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onTap: () {
                            Get.back();
                            controller.assign(task, staff.id);
                          },
                        ),
                      )
                      .toList(),
                );
              }),
            ),
          ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _TaskCard extends StatelessWidget {
  final HkTaskModel task;
  final bool canUpdate;
  final bool canAssign;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onAssign;

  const _TaskCard({
    required this.task,
    required this.canUpdate,
    required this.canAssign,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = taskStatusColor(task.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: statusColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tor ekranda uzun xona raqami kartadan chiqib ketmasin
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 96),
                        child: Text(
                          task.roomNumber.isEmpty ? '—' : task.roomNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(
                            fontSize: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          HkTaskModel.typeLabel(task.taskType),
                          style: AppTextStyles.bodyLg(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: AdminChip(
                          label: HkTaskModel.statusLabel(task.status),
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AdminChip(
                        label: HkTaskModel.priorityLabel(task.priority),
                        color: priorityColor(task.priority),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          // Uzun ism Wrap ichidagi Row'dan toshib ketmasin
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: Text(
                              task.assigneeName.isEmpty
                                  ? 'Biriktirilmagan'.tr
                                  : task.assigneeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.scheduledDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_rounded,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.scheduledDate!,
                              style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (task.isActive && (canUpdate || canAssign)) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (canUpdate && task.isOpen)
                          _actionButton(
                            'Boshlash'.tr,
                            AppColors.primaryContainer,
                            AppColors.onPrimary,
                            Icons.play_arrow_rounded,
                            onStart,
                          ),
                        if (canUpdate && task.isInProgress)
                          _actionButton(
                            'Yakunlash'.tr,
                            AppColors.primaryContainer,
                            AppColors.onPrimary,
                            Icons.check_circle_rounded,
                            onComplete,
                          ),
                        if (canAssign)
                          _actionButton(
                            'Biriktirish'.tr,
                            AppColors.surfaceContainer,
                            AppColors.primary,
                            Icons.person_add_alt_rounded,
                            onAssign,
                          ),
                        if (canUpdate)
                          _actionButton(
                            'Bekor qilish'.tr,
                            AppColors.surfaceContainer,
                            AppColors.error,
                            Icons.close_rounded,
                            onCancel,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.statusBadge(color: textColor)),
          ],
        ),
      ),
    );
  }
}
