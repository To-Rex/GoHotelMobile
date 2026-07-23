import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../data/models/task_model.dart';
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
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.onSurface),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Xona ${currentTask.roomNumber}',
            style: AppTextStyles.h2(),
          ),
          actions: [
            TextButton.icon(
              onPressed: () =>
                  Get.toNamed('/problem-report', arguments: currentTask),
              icon: const Icon(Icons.report_problem_outlined,
                  size: 18, color: AppColors.error),
              label: Text('Muammo',
                  style: AppTextStyles.bodyMd(color: AppColors.error)),
            ),
            TextButton.icon(
              onPressed: () =>
                  Get.toNamed('/photo-report', arguments: currentTask),
              icon: const Icon(Icons.photo_camera_rounded,
                  size: 18, color: AppColors.primary),
              label: Text('Hisobot',
                  style: AppTextStyles.bodyMd(color: AppColors.primary)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(index: 0, child: _buildInfoGrid(currentTask)),
              const SizedBox(height: 24),
              FadeSlideIn(
                index: 2,
                child:
                    Text('Tekshirish ro\'yxati', style: AppTextStyles.h2()),
              ),
              const SizedBox(height: 12),
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
        floatingActionButton:
            _buildCompleteButton(currentTask, tasksController),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }

  Widget _buildInfoGrid(TaskModel task) {
    return Column(
      children: [
        Row(
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
                    Text('QAVAT', style: AppTextStyles.labelCaps()),
                    const SizedBox(height: 6),
                    Text(task.floor, style: AppTextStyles.h2()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.roomType,
                            style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant),
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
                    Text('HOLAT', style: AppTextStyles.labelCaps()),
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
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Priority',
                          style:
                              AppTextStyles.labelCaps(color: AppColors.onError),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
                    Text('JARAYON', style: AppTextStyles.labelCaps()),
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
    if (task.isUrgent) return 'Shoshilinch';
    switch (task.status) {
      case TaskStatus.pending:
        return 'Kutilmoqda';
      case TaskStatus.inProgress:
        return 'Jarayonda';
      case TaskStatus.completed:
        return 'Yakunlangan';
    }
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
          left: BorderSide(
            color: AppColors.secondaryContainer,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_late_rounded,
              color: AppColors.primary, size: 20),
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
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.onPrimary, size: 26),
              AnimatedSize(
                duration: AppMotion.base,
                curve: AppMotion.emphasized,
                child: allDone
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Yakunlash',
                          style: AppTextStyles.bodyLg(
                              color: AppColors.onPrimary),
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
