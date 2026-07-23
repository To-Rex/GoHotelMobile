import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_model.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(
              title: 'GoHotel Service',
              subtitle: 'Xodim profili',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(index: 1, child: _buildWelcomeCard(context)),
                      const SizedBox(height: 20),
                      FadeSlideIn(index: 2, child: _buildStatsGrid()),
                      const SizedBox(height: 28),
                      FadeSlideIn(index: 3, child: _buildTasksHeader()),
                      const SizedBox(height: 14),
                      _buildTasksList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BUGUNGI SMENA',
                    style: AppTextStyles.labelCaps(color: AppColors.primary)),
                const SizedBox(height: 6),
                Text('Xush kelibsiz!', style: AppTextStyles.h1()),
                const SizedBox(height: 4),
                Text(
                  'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.',
                  style:
                      AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildProgressRing(),
        ],
      ),
    );
  }

  Widget _buildProgressRing() {
    return Obx(() {
      final progress = controller.overallProgress.value;
      return Column(
        children: [
          AnimatedProgressRing(
            value: progress,
            size: 72,
            strokeWidth: 7,
            textStyle: AppTextStyles.h2(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Bajarilish',
              style: AppTextStyles.labelCaps(color: AppColors.primary),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatsGrid() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Yakunlandi',
              count: controller.completedTasks.value,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Kutilmoqda',
              count: controller.pendingTasks.value,
              icon: Icons.pending_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Muammo',
              count: controller.problemTasks.value,
              icon: Icons.report_problem_rounded,
              iconColor: AppColors.error,
              onTap: () => Get.toNamed('/problem-report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Bugungi vazifalar', style: AppTextStyles.h2()),
        Pressable(
          onTap: () => Get.toNamed('/tasks'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hammasi',
                  style: AppTextStyles.statusBadge(color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Obx(
      () => Column(
        children: controller.todayTasks
            .asMap()
            .entries
            .map((entry) => FadeSlideIn(
                  index: 4 + entry.key,
                  child: TaskCard(
                    task: entry.value,
                    onTap: () =>
                        Get.toNamed('/room-details', arguments: entry.value),
                    onStart: () {
                      if (entry.value.status == TaskStatus.pending) {
                        Get.find<TasksController>().startTask(entry.value.id);
                        controller.loadData();
                      }
                    },
                    onFinish: () =>
                        Get.toNamed('/room-details', arguments: entry.value),
                    onReport: () =>
                        Get.toNamed('/photo-report', arguments: entry.value),
                    onProblemReport: () =>
                        Get.toNamed('/problem-report', arguments: entry.value),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
