import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_model.dart';
import '../controllers/tasks_controller.dart';

class TasksPage extends GetView<TasksController> {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Mening vazifalarim',
              subtitle: 'Bugun, 24-Oktyabr',
            ),
            const SizedBox(height: 12),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTasks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => _buildTabContent()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab('Kutilmoqda', 0, controller.pendingTasks.length),
            _buildTab('Jarayonda', 1, controller.inProgressTasks.length),
            _buildTab('Yakunlangan', 2, controller.completedTasks.length),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.onSurface.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.statusBadge(
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.labelCaps(
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final tasks = switch (controller.selectedTab.value) {
      0 => controller.pendingTasks,
      1 => controller.inProgressTasks,
      2 => controller.completedTasks,
      _ => <TaskModel>[],
    };

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_turned_in,
        message: 'Hozircha vazifalar yo\'q',
      );
    }

    return Column(
      children: tasks
          .map((task) => TaskCard(
                task: task,
                onTap: () => Get.toNamed('/room-details', arguments: task),
                onStart: () => controller.startTask(task.id),
                onFinish: () => Get.toNamed('/room-details', arguments: task),
                onReport: () => Get.toNamed('/photo-report', arguments: task),
                onProblemReport: () => Get.toNamed('/problem-report', arguments: task),
              ))
          .toList(),
    );
  }
}
