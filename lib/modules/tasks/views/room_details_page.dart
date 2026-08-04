import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../data/models/occupied_room_model.dart';
import '../../../data/models/task_model.dart';
import '../controllers/room_details_controller.dart';
import '../controllers/tasks_controller.dart';

class RoomDetailsPage extends StatelessWidget {
  const RoomDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Get.arguments as TaskModel;
    final tasksController = Get.find<TasksController>();

    return Obx(() {
      final currentTask = tasksController.tasks.firstWhere(
        (t) => t.id == task.id,
        orElse: () => task,
      );

      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            '${'Xona'.tr} ${currentTask.roomNumber}',
            style: AppTextStyles.h2(),
          ),
          actions: [
            TextButton.icon(
              onPressed: () =>
                  Get.toNamed('/problem-report', arguments: currentTask),
              icon: const Icon(
                Icons.report_problem_outlined,
                size: 18,
                color: AppColors.error,
              ),
              label: Text(
                'Muammo'.tr,
                style: AppTextStyles.bodyMd(color: AppColors.error),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Get.toNamed('/photo-report', arguments: currentTask),
              icon: const Icon(
                Icons.photo_camera_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Hisobot'.tr,
                style: AppTextStyles.bodyMd(color: AppColors.primary),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(index: 0, child: _buildInfoGrid(currentTask)),
              const SizedBox(height: 16),
              FadeSlideIn(index: 1, child: _buildDetailsCard(currentTask)),
              const SizedBox(height: 24),
              FadeSlideIn(
                index: 2,
                child: Text(
                  'Tekshirish ro\'yxati'.tr,
                  style: AppTextStyles.h2(),
                ),
              ),
              const SizedBox(height: 12),
              if (currentTask.checklist.isEmpty)
                FadeSlideIn(index: 3, child: _buildEmptyChecklist())
              else
                _buildChecklist(currentTask, tasksController),
              if (currentTask.note != null) ...[
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 4 + currentTask.checklist.length,
                  child: _buildNote(currentTask.note!),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
        floatingActionButton: _buildCompleteButton(
          currentTask,
          tasksController,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }

  Widget _buildInfoGrid(TaskModel task) {
    return Column(
      children: [
        // IntrinsicHeight shart: stretch scroll ichida cheksiz balandlik olib,
        // butun sahifani oppoq qilib qo'yadi (layout exception).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QAVAT'.tr, style: AppTextStyles.labelCaps()),
                      const SizedBox(height: 6),
                      Text(task.floor, style: AppTextStyles.h2()),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.roomType,
                              style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: task.isUrgent
                        ? AppColors.errorContainer
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: task.isUrgent
                        ? AppShadows.glow(AppColors.error, alpha: 0.15)
                        : AppShadows.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HOLAT'.tr, style: AppTextStyles.labelCaps()),
                      const SizedBox(height: 6),
                      Text(
                        _statusText(task),
                        style: AppTextStyles.h2(
                          color: task.isUrgent
                              ? AppColors.onErrorContainer
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (task.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Priority',
                            style: AppTextStyles.labelCaps(
                              color: AppColors.onError,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (task.status != TaskStatus.completed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('JARAYON'.tr, style: AppTextStyles.labelCaps()),
                    AnimatedCount(
                      value: task.progress,
                      suffix: '%',
                      style: AppTextStyles.h2(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedProgressBar(value: task.progress / 100, height: 9),
              ],
            ),
          ),
      ],
    );
  }

  String _statusText(TaskModel task) {
    if (task.isUrgent) return 'Shoshilinch'.tr;
    switch (task.status) {
      case TaskStatus.pending:
        return 'Kutilmoqda'.tr;
      case TaskStatus.inProgress:
        return 'Jarayonda'.tr;
      case TaskStatus.completed:
        return 'Yakunlangan'.tr;
    }
  }

  Widget _buildDetailsCard(TaskModel task) {
    final detailsController = Get.find<RoomDetailsController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QO\'SHIMCHA MA\'LUMOT'.tr, style: AppTextStyles.labelCaps()),
          const SizedBox(height: 14),
          _detailRow(
            Icons.person_outline_rounded,
            'Mehmon'.tr,
            task.guest ?? 'Ma\'lumot yo\'q'.tr,
            trailing: task.guestStatus != null
                ? _statusChip(task.guestStatus!)
                : null,
          ),
          _rowDivider(),
          _detailRow(
            Icons.schedule_rounded,
            'Tozalash muddati'.tr,
            task.deadline ?? 'Belgilanmagan'.tr,
          ),
          _rowDivider(),
          Obx(() {
            final info = detailsController.occupiedInfo.value;
            final loading = detailsController.isLoadingOccupied.value;

            String value;
            Widget? trailing;
            if (loading) {
              value = 'Tekshirilmoqda...'.tr;
            } else if (info == null) {
              value = 'Xona hozir band emas'.tr;
            } else {
              value = '${'Chiqish'.tr}: ${info.checkoutLabel}';
              final minutes = info.minutesUntilCheckout;
              final Color color;
              final Color bg;
              if (minutes < 0) {
                color = AppColors.error;
                bg = AppColors.errorContainer;
              } else if (minutes <= 60) {
                color = AppColors.statusInProgress;
                bg = AppColors.statusInProgressBg;
              } else {
                color = AppColors.statusCleaned;
                bg = AppColors.statusCleanedBg;
              }
              trailing = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  OccupiedRoomModel.formatRemaining(minutes),
                  style: AppTextStyles.labelCaps(color: color),
                ),
              );
            }

            return _detailRow(
              Icons.meeting_room_rounded,
              'Xona bandligi'.tr,
              value,
              trailing: trailing,
            );
          }),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelCaps()),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd(),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  Widget _statusChip(String status) {
    final isActive = status == 'Band';
    final color = isActive
        ? AppColors.statusInProgress
        : AppColors.statusCleaned;
    final bg = isActive
        ? AppColors.statusInProgressBg
        : AppColors.statusCleanedBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.tr, style: AppTextStyles.labelCaps(color: color)),
    );
  }

  Widget _rowDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.outlineVariant.withValues(alpha: 0.3),
    );
  }

  Widget _buildEmptyChecklist() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checklist_rtl_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ro\'yxat biriktirilmagan'.tr,
                  style: AppTextStyles.bodyLg(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xonani standart tartibda tozalang va yakunida fotohisobot yuboring.'
                      .tr,
                  style: AppTextStyles.bodyMd(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(TaskModel task, TasksController controller) {
    return Column(
      children: task.checklist.asMap().entries.map((entry) {
        final item = entry.value;
        return FadeSlideIn(
          index: 3 + entry.key,
          child: Pressable(
            onTap: () => controller.toggleChecklistItem(task.id, item.id),
            pressedScale: 0.98,
            child: AnimatedContainer(
              duration: AppMotion.base,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? AppColors.surfaceContainerLow
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isCompleted
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: item.isCompleted ? null : AppShadows.soft,
              ),
              child: Row(
                children: [
                  BouncyCheck(checked: item.isCompleted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: AppMotion.base,
                      style: AppTextStyles.bodyLg().copyWith(
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isCompleted
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                      child: Text(item.title),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNote(String note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppColors.secondaryContainer, width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_late_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(TaskModel task, TasksController controller) {
    if (task.status == TaskStatus.completed) return const SizedBox();

    final allDone = task.checklist.every((c) => c.isCompleted);
    return SoftPulse(
      active: allDone,
      child: Pressable(
        onTap: () => Get.toNamed('/photo-report', arguments: task),
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: Curves.easeOut,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: allDone ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: allDone
                  ? [AppColors.success, AppColors.statusCleaned]
                  : const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.glow(
              allDone ? AppColors.success : AppColors.primary,
              alpha: 0.35,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.onPrimary,
                size: 26,
              ),
              AnimatedSize(
                duration: AppMotion.base,
                curve: AppMotion.emphasized,
                child: allDone
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Yakunlash'.tr,
                          style: AppTextStyles.bodyLg(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
