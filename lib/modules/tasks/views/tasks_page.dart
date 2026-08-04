import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
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
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Mening vazifalarim'.tr,
              subtitle: 'Bugun, 24-Oktyabr'.tr,
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildTabBar()),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTasks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: AppMotion.base,
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(controller.selectedTab.value),
                        child: _buildTabContent(),
                      ),
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

  Widget _buildTabBar() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildTab('Kutilmoqda'.tr, 0, controller.pendingTasks.length),
            _buildTab('Jarayonda'.tr, 1, controller.inProgressTasks.length),
            _buildTab('Yakunlangan'.tr, 2, controller.completedTasks.length),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isActive = controller.selectedTab.value == index;
    return Expanded(
      child: Pressable(
        onTap: () => controller.changeTab(index),
        pressedScale: 0.96,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.onSurface.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppTextStyles.statusBadge(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedContainer(
                  duration: AppMotion.base,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.labelCaps(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
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
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: Icons.assignment_turned_in_rounded,
          message: 'Hozircha vazifalar yo\'q'.tr,
        ),
      );
    }

    return Column(
      children: tasks
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideIn(
              index: entry.key,
              child: TaskCard(
                task: entry.value,
                onTap: () =>
                    Get.toNamed('/room-details', arguments: entry.value),
                onStart: () => controller.startTask(entry.value.id),
                onFinish: () =>
                    Get.toNamed('/room-details', arguments: entry.value),
                onReport: () =>
                    Get.toNamed('/photo-report', arguments: entry.value),
                onProblemReport: () =>
                    Get.toNamed('/problem-report', arguments: entry.value),
              ),
            ),
          )
          .toList(),
    );
  }
}
