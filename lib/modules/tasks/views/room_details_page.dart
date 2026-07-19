import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
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
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
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
              icon: const Icon(Icons.report_problem_outlined, size: 18),
              label: Text('Muammo',
                  style: AppTextStyles.bodyMd(color: AppColors.error)),
            ),
            TextButton.icon(
              onPressed: () =>
                  Get.toNamed('/photo-report', arguments: currentTask),
              icon: const Icon(Icons.photo_camera, size: 18),
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
              _buildInfoGrid(currentTask),
              const SizedBox(height: 20),
              Text('Tekshirish ro\'yxati', style: AppTextStyles.h2()),
              const SizedBox(height: 12),
              _buildChecklist(currentTask, tasksController),
              if (currentTask.note != null) ...[
                const SizedBox(height: 16),
                _buildNote(currentTask.note!),
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
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qavat', style: AppTextStyles.labelCaps()),
                    const SizedBox(height: 4),
                    Text(task.floor, style: AppTextStyles.h2()),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: task.isUrgent
                      ? AppColors.errorContainer
                      : AppColors.surfaceContainerLowest,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Holat', style: AppTextStyles.labelCaps()),
                    const SizedBox(height: 4),
                    Text(
                      _statusText(task),
                      style: AppTextStyles.h2(
                        color: task.isUrgent
                            ? AppColors.onErrorContainer
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                          style: AppTextStyles.labelCaps(
                              color: AppColors.onError),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jarayon', style: AppTextStyles.labelCaps()),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progress / 100,
                    backgroundColor: AppColors.surfaceContainer,
                    color: AppColors.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.progress}%',
                  style: AppTextStyles.bodyLg(color: AppColors.primary),
                ),
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
      children: task.checklist.map((item) {
        return GestureDetector(
          onTap: () =>
              controller.toggleChecklistItem(task.id, item.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.isCompleted
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: 2,
                    ),
                    color: item.isCompleted ? AppColors.primary : Colors.transparent,
                  ),
                  child: item.isCompleted
                      ? const Icon(Icons.check,
                          size: 18, color: AppColors.onPrimary)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTextStyles.bodyLg().copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isCompleted
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColors.secondaryContainer,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_late,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: allDone
            ? AppColors.secondaryContainer
            : AppColors.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: (allDone ? AppColors.secondary : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          Get.toNamed('/photo-report', arguments: task);
        },
        icon: Icon(
          Icons.check_circle,
          color: AppColors.onPrimary,
          size: 32,
        ),
      ),
    );
  }
}
