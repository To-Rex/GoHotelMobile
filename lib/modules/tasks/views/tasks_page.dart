import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/layout/layout.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_model.dart';
import '../controllers/tasks_controller.dart';

/// The task screen is a queue board: an adaptive lane selector stays beside
/// the work on larger displays and becomes a compact scrollable selector on
/// phones and watch-sized displays.
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
            ResponsiveSection(
              maxWidth: 980,
              child: AppHeader(
                title: 'Mening vazifalarim'.tr,
                subtitle: _todaySubtitle(),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final expanded = constraints.maxWidth >= 720;
                  final ultraCompact = constraints.maxWidth < 260;

                  if (expanded) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 16, 24),
                          child: SizedBox(width: 220, child: _buildQueueRail()),
                        ),
                        Container(
                          width: 1,
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        Expanded(child: _buildQueueContent()),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          ultraCompact ? 0 : 4,
                          4,
                          ultraCompact ? 0 : 4,
                          12,
                        ),
                        child: FadeSlideIn(index: 0, child: _buildTabBar()),
                      ),
                      Expanded(child: _buildQueueContent()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _todaySubtitle() {
    final today = DateTime.now();
    final monthIndex = today.month - 1;

    switch (Get.locale?.languageCode) {
      case 'ru':
        return 'Сегодня, ${today.day} ${_russianMonths[monthIndex]}';
      case 'en':
        return 'Today, ${_englishMonths[monthIndex]} ${today.day}';
      default:
        return 'Bugun, ${today.day}-${_uzbekMonths[monthIndex]}';
    }
  }

  static const _uzbekMonths = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentyabr',
    'oktyabr',
    'noyabr',
    'dekabr',
  ];

  static const _russianMonths = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  static const _englishMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Widget _buildQueueRail() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.42),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRailTab('Kutilmoqda'.tr, 0, controller.pendingTasks.length),
            const SizedBox(height: 4),
            _buildRailTab('Jarayonda'.tr, 1, controller.inProgressTasks.length),
            const SizedBox(height: 4),
            _buildRailTab(
              'Yakunlangan'.tr,
              2,
              controller.completedTasks.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailTab(String label, int index, int count) {
    final selected = controller.selectedTab.value == index;
    return Pressable(
      onTap: () => controller.changeTab(index),
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.statusBadge(
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCountBadge(count, selected: selected),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(
      () {
        // MUHIM: observable'lar Obx builder'ining O'ZIDA o'qiladi —
        // LayoutBuilder callback'i layout paytida (Obx kuzatuvidan tashqarida)
        // chaqiriladi va GetX "improper use" xatosini otardi.
        final pendingCount = controller.pendingTasks.length;
        final inProgressCount = controller.inProgressTasks.length;
        final completedCount = controller.completedTasks.length;
        final selectedTab = controller.selectedTab.value;
        return LayoutBuilder(
        builder: (context, constraints) {
          final tabs = [
            _buildTab('Kutilmoqda'.tr, 0, pendingCount, selectedTab == 0),
            _buildTab('Jarayonda'.tr, 1, inProgressCount, selectedTab == 1),
            _buildTab('Yakunlangan'.tr, 2, completedCount, selectedTab == 2),
          ];
          final ultraCompact = constraints.maxWidth < 260;
          final narrow = constraints.maxWidth < 420;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: ultraCompact ? 10 : 20),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.42),
              ),
            ),
            child: narrow
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var index = 0; index < tabs.length; index++)
                          SizedBox(
                            width: ultraCompact ? 112 : 136,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == tabs.length - 1 ? 0 : 4,
                              ),
                              child: tabs[index],
                            ),
                          ),
                      ],
                    ),
                  )
                : Row(children: [for (final tab in tabs) Expanded(child: tab)]),
          );
        },
        );
      },
    );
  }

  Widget _buildTab(String label, int index, int count, bool selected) {
    return Pressable(
      onTap: () => controller.changeTab(index),
      pressedScale: 0.96,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
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
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildCountBadge(count, selected: selected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count, {required bool selected}) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.labelCaps(
          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildQueueContent() {
    return Obx(() {
      final tab = controller.selectedTab.value;
      final tasks = switch (tab) {
        0 => controller.pendingTasks,
        1 => controller.inProgressTasks,
        2 => controller.completedTasks,
        _ => <TaskModel>[],
      };

      return RefreshIndicator(
        onRefresh: controller.loadTasks,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ultraCompact = constraints.maxWidth < 260;
            final gutter = ultraCompact ? 10.0 : 20.0;
            final queueLabel = switch (tab) {
              0 => 'Kutilmoqda'.tr,
              1 => 'Jarayonda'.tr,
              2 => 'Yakunlangan'.tr,
              _ => '',
            };

            return CustomScrollView(
              key: PageStorageKey('task-queue-$tab'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: _buildQueueHeading(queueLabel, tasks.length),
                      ),
                    ),
                  ),
                ),
                if (tasks.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 110),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 840),
                          child: EmptyState(
                            icon: Icons.assignment_turned_in_rounded,
                            message: 'Hozircha vazifalar yo\'q'.tr,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = tasks[index];
                        final card = _buildTaskCard(task);
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 840),
                            child: index < 5
                                ? FadeSlideIn(index: index, child: card)
                                : card,
                          ),
                        );
                      }, childCount: tasks.length),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildQueueHeading(String label, int count) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: AppTextStyles.h2())),
        Text(
          '$count',
          style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return TaskCard(
      task: task,
      onTap: () => Get.toNamed('/room-details', arguments: task),
      onStart: () => controller.startTask(task.id),
      onFinish: () => Get.toNamed('/room-details', arguments: task),
      onReport: () => Get.toNamed('/photo-report', arguments: task),
      onProblemReport: () => Get.toNamed('/problem-report', arguments: task),
    );
  }
}
