import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/occupied_room_card.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_model.dart';
import '../../occupied_rooms/controllers/occupied_rooms_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_controller.dart';

/// Staff home is a work surface rather than a dashboard: the next room is
/// first, the remaining queue follows lazily, and supporting operations stay
/// grouped alongside it.
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: AppHeader(
                  title: 'Go Hotel',
                  subtitle: 'Xodim profili'.tr,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final ultraCompact = constraints.maxWidth < 260;
                  final gutter = constraints.maxWidth >= 600
                      ? 28.0
                      : ultraCompact
                      ? 10.0
                      : 16.0;
                  final wide = constraints.maxWidth >= 900;

                  return Obx(() {
                    final tasks = List<TaskModel>.from(controller.todayTasks);
                    final focusTask = _selectFocusTask(tasks);
                    final queue = _remainingQueue(tasks, focusTask);
                    final roomsController = Get.find<OccupiedRoomsController>();

                    return RefreshIndicator(
                      onRefresh: controller.refreshData,
                      child: CustomScrollView(
                        key: const PageStorageKey('staff-home-work-surface'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              gutter,
                              ultraCompact ? 4 : 10,
                              gutter,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1120,
                                  ),
                                  child: _buildWorkOverview(
                                    focusTask: focusTask,
                                    roomsController: roomsController,
                                    wide: wide,
                                    ultraCompact: ultraCompact,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              gutter,
                              ultraCompact ? 20 : 30,
                              gutter,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 840,
                                  ),
                                  child: _buildQueueHeader(
                                    count: queue.length,
                                    ultraCompact: ultraCompact,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (queue.isEmpty)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                16,
                                gutter,
                                110,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 840,
                                    ),
                                    child: _buildQueueEmptyState(),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                14,
                                gutter,
                                110,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final task = queue[index];
                                  final card = _buildTaskCard(task);
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 840,
                                      ),
                                      child: index < 4
                                          ? FadeSlideIn(
                                              index: index + 1,
                                              child: card,
                                            )
                                          : card,
                                    ),
                                  );
                                }, childCount: queue.length),
                              ),
                            ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TaskModel? _selectFocusTask(List<TaskModel> tasks) {
    for (final task in tasks) {
      if (task.status == TaskStatus.inProgress) return task;
    }
    for (final task in tasks) {
      if (task.status == TaskStatus.pending) return task;
    }
    return null;
  }

  List<TaskModel> _remainingQueue(List<TaskModel> tasks, TaskModel? focusTask) {
    if (focusTask == null) return tasks;
    final focusIndex = tasks.indexWhere((task) => task.id == focusTask.id);
    if (focusIndex < 0) return tasks;
    return [...tasks.take(focusIndex), ...tasks.skip(focusIndex + 1)];
  }

  Widget _buildWorkOverview({
    required TaskModel? focusTask,
    required OccupiedRoomsController roomsController,
    required bool wide,
    required bool ultraCompact,
  }) {
    final primaryWork = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(index: 0, child: _buildShiftSummary()),
        if (focusTask != null) ...[
          SizedBox(height: ultraCompact ? 18 : 24),
          _buildFocusSection(focusTask),
        ],
      ],
    );
    final operations = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOperationalLinks(),
        SizedBox(height: ultraCompact ? 18 : 24),
        _buildOccupiedPreview(roomsController),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: primaryWork),
          const SizedBox(width: 24),
          SizedBox(width: 340, child: operations),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        primaryWork,
        SizedBox(height: ultraCompact ? 22 : 30),
        operations,
      ],
    );
  }

  Widget _buildShiftSummary() {
    return Obx(
      () {
        // MUHIM: observable'lar Obx builder'ining O'ZIDA o'qiladi —
        // LayoutBuilder callback'i layout paytida (Obx kuzatuvidan tashqarida)
        // chaqiriladi va GetX "improper use" xatosini otardi.
        final progress = (controller.overallProgress.value * 100).round();
        final completedLabel = '${controller.completedTasks.value}';
        final pendingLabel = '${controller.pendingTasks.value}';
        final problemsLabel = '${controller.problemTasks.value}';
        return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inverseSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.1)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final metrics = [
              _buildMetric(completedLabel, 'Yakunlandi'.tr),
              _buildMetric(pendingLabel, 'Kutilmoqda'.tr),
              _buildMetric(problemsLabel, 'Muammo'.tr),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BUGUNGI SMENA'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelCaps(
                              color: AppColors.inverseOnSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Xush kelibsiz!'.tr,
                            style: AppTextStyles.h1(
                              color: AppColors.inverseOnSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.'.tr,
                            maxLines: compact ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMd(
                              color: AppColors.inverseOnSurface.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$progress%',
                        style: AppTextStyles.display(
                          fontSize: compact ? 22 : 26,
                          color: AppColors.inverseOnSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  color: AppColors.onPrimary.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 14),
                if (compact)
                  Wrap(spacing: 14, runSpacing: 12, children: metrics)
                else
                  Row(
                    children: [
                      Expanded(child: metrics[0]),
                      Expanded(child: metrics[1]),
                      Expanded(child: metrics[2]),
                    ],
                  ),
              ],
            );
          },
        ),
        );
      },
    );
  }

  Widget _buildMetric(String value, String label) {
    return SizedBox(
      width: 78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.h2(color: AppColors.inverseOnSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd(
              color: AppColors.inverseOnSurface.withValues(alpha: 0.68),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          task.status == TaskStatus.inProgress
              ? 'Jarayonda'.tr
              : 'Kutilmoqda'.tr,
        ),
        const SizedBox(height: 12),
        FadeSlideIn(index: 1, child: _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildOperationalLinks() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 620;
          final messages = _buildOperationLink(
            title: 'Xabarlar taxtasi'.tr,
            subtitle: 'So\'rov yuboring — jamoa darhol ko\'radi'.tr,
            onTap: () => Get.toNamed('/staff-messages'),
          );
          final rooms = _buildOperationLink(
            title: 'Band xonalar'.tr,
            subtitle: 'Xonalar qachon bo\'shashini ko\'ring'.tr,
            onTap: () => Get.toNamed('/occupied-rooms'),
          );

          if (horizontal) {
            return Row(
              children: [
                Expanded(child: messages),
                Container(
                  width: 1,
                  height: 52,
                  color: AppColors.outlineVariant.withValues(alpha: 0.45),
                ),
                Expanded(child: rooms),
              ],
            );
          }

          return Column(
            children: [
              messages,
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.outlineVariant.withValues(alpha: 0.45),
              ),
              rooms,
            ],
          );
        },
      ),
    );
  }

  Widget _buildOperationLink({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLg(),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.inverseSurface,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupiedPreview(OccupiedRoomsController roomsController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Band xonalar'.tr,
          action: _buildRouteAction(
            onTap: () => Get.toNamed('/occupied-rooms'),
          ),
        ),
        const SizedBox(height: 12),
        if (roomsController.isLoading.value && roomsController.rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (roomsController.rooms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: EmptyState(
              icon: Icons.night_shelter_rounded,
              message: 'Hozircha band xonalar yo\'q'.tr,
            ),
          )
        else
          Column(
            children: roomsController.rooms
                .take(2)
                .map(
                  (room) => OccupiedRoomCard(
                    room: room,
                    minutesLeft: roomsController.minutesLeft(room),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildQueueHeader({required int count, required bool ultraCompact}) {
    return _buildSectionTitle(
      'Bugungi vazifalar'.tr,
      trailing: Text(
        '$count',
        style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
      ),
      action: _buildRouteAction(
        onTap: () => Get.find<MainController>().changeTab(1),
        iconOnly: ultraCompact,
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing, Widget? action}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 280;
        final heading = Row(
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
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2(),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        );

        if (action == null) return heading;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 10),
            action,
          ],
        );
      },
    );
  }

  Widget _buildRouteAction({
    required VoidCallback onTap,
    bool iconOnly = false,
  }) {
    return Semantics(
      label: 'Hammasi'.tr,
      button: true,
      child: Tooltip(
        message: 'Hammasi'.tr,
        child: Pressable(
          onTap: onTap,
          child: Container(
            width: iconOnly ? 38 : null,
            height: 36,
            padding: iconOnly
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: iconOnly
                ? const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.inverseSurface,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hammasi'.tr,
                        style: AppTextStyles.statusBadge(
                          color: AppColors.inverseSurface,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.inverseSurface,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueEmptyState() {
    return EmptyState(
      icon: Icons.assignment_turned_in_rounded,
      message: 'Hozircha vazifalar yo\'q'.tr,
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return TaskCard(
      task: task,
      onTap: () => Get.toNamed('/room-details', arguments: task),
      onStart: () {
        if (task.status == TaskStatus.pending) {
          Get.find<TasksController>().startTask(task.id);
          controller.loadData();
        }
      },
      onFinish: () => Get.toNamed('/room-details', arguments: task),
      onReport: () => Get.toNamed('/photo-report', arguments: task),
      onProblemReport: () => Get.toNamed('/problem-report', arguments: task),
    );
  }
}
