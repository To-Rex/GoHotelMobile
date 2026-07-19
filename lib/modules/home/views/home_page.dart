import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(context),
                      const SizedBox(height: 20),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildTasksHeader(),
                      const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xush kelibsiz!', style: AppTextStyles.h1()),
                const SizedBox(height: 4),
                Text(
                  'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.',
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
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
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ProgressRingPainter(progress),
              child: Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.h2(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
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
              icon: Icons.check_circle,
              iconColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Kutilmoqda',
              count: controller.pendingTasks.value,
              icon: Icons.pending,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Muammo',
              count: controller.problemTasks.value,
              icon: Icons.report_problem,
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
        GestureDetector(
          onTap: () => Get.toNamed('/tasks'),
          child: Text(
            'Hammasi \u2192',
            style: AppTextStyles.bodyMd(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Obx(
      () => Column(
        children: controller.todayTasks
            .map((task) => TaskCard(
                  task: task,
                  onTap: () => Get.toNamed('/room-details', arguments: task),
                  onStart: () {
                    if (task.status == TaskStatus.pending) {
                      Get.find<TasksController>().startTask(task.id);
                      controller.loadData();
                    }
                  },
                  onFinish: () => Get.toNamed('/room-details', arguments: task),
                  onReport: () =>
                      Get.toNamed('/photo-report', arguments: task),
                  onProblemReport: () => Get.toNamed('/problem-report', arguments: task),
                ))
            .toList(),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = AppColors.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [AppColors.primary, AppColors.secondaryContainer],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
