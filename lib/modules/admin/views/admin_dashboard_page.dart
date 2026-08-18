import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/models/hk_task_model.dart';
import '../../../data/models/room_model.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_main_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

/// Boshqaruvdagi kundalik ish stoli.
///
/// Sahifa ko'rsatkichlarni ketma-ket kartalarga ajratmaydi: yuqorida joriy
/// holat va navbatdagi ish, so'ng vazifalar oqimi hamda xonalar holati bir
/// workspaceda jamlanadi. Kenglik oshganda bu bloklar yonma-yon, tor ekranda
/// esa tabiiy ketma-ket ko'rinadi.
class AdminDashboardPage extends GetView<AdminDashboardController> {
  const AdminDashboardPage({super.key});

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
              title: 'Boshqaruv paneli'.tr,
              subtitle: main.roleLabel.tr,
              leading: const DrawerMenuButton(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gutter = adminPageGutterForWidth(constraints.maxWidth);
                  return AdminContentConstraint(
                    child: RefreshIndicator(
                      onRefresh: controller.loadData,
                      child: Obx(() => _buildWorkspace(context, main, gutter)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace(
    BuildContext context,
    AdminMainController main,
    double gutter,
  ) {
    if (controller.isLoading.value &&
        controller.rooms.isEmpty &&
        controller.tasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
        children: const [AdminSkeletonList(count: 4, height: 118)],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
      children: [
        FadeSlideIn(index: 0, child: _buildCurrentState(main)),
        if (controller.errorMessage.value != null) ...[
          const SizedBox(height: 10),
          _buildErrorState(),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 720;
            final taskFlow = _buildTaskFlow(main);
            final roomStatus = _buildRoomStatusWorkspace();
            if (!sideBySide) {
              return Column(
                children: [
                  FadeSlideIn(index: 1, child: taskFlow),
                  const SizedBox(height: 12),
                  FadeSlideIn(index: 2, child: roomStatus),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: FadeSlideIn(index: 1, child: taskFlow),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: FadeSlideIn(index: 2, child: roomStatus),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        FadeSlideIn(index: 3, child: _buildActiveTaskQueue(main)),
      ],
    );
  }

  /// Asosiy holat va uni bosib hal qilinadigan navbatdagi ish.
  Widget _buildCurrentState(AdminMainController main) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final veryCompact = constraints.maxWidth < 260;
        final ringSize = compact ? 58.0 : 70.0;
        final stateSummary = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UMUMIY HOLAT'.tr,
              style: AppTextStyles.labelCaps(
                color: AppColors.onPrimary.withValues(alpha: 0.80),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Xush kelibsiz!'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h1(color: AppColors.onPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _heroMetric(
                  Icons.meeting_room_rounded,
                  '${controller.totalRooms} ${'ta xona'.tr}',
                ),
                _heroMetric(
                  Icons.check_circle_outline_rounded,
                  '${controller.statusCount('AVAILABLE')} ${'bo\'sh'.tr}',
                ),
              ],
            ),
          ],
        );
        final occupancy = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: AnimatedProgressRing(
                value: controller.occupancy,
                size: ringSize,
                strokeWidth: compact ? 6 : 7,
                textStyle: AppTextStyles.h2(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bandlik'.tr,
              style: AppTextStyles.labelCaps(
                color: AppColors.onPrimary.withValues(alpha: 0.88),
              ),
            ),
          ],
        );
        final nextAction = _nextAction(main, compact: compact);

        return Container(
          padding: EdgeInsets.all(compact ? 14 : 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(compact ? 20 : 24),
          ),
          child: veryCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stateSummary,
                    const SizedBox(height: 16),
                    occupancy,
                    const SizedBox(height: 12),
                    nextAction,
                  ],
                )
              : compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stateSummary,
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        occupancy,
                        const SizedBox(width: 14),
                        Expanded(child: nextAction),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: stateSummary),
                    const SizedBox(width: 14),
                    occupancy,
                    const SizedBox(width: 14),
                    SizedBox(width: 176, child: nextAction),
                  ],
                ),
        );
      },
    );
  }

  Widget _heroMetric(IconData icon, String label) {
    return ConstrainedBox(
      // Watch-width hero cards have only ~136dp of useful width.  Keep each
      // metric self-contained so the long Uzbek label truncates rather than
      // letting its icon row overflow.
      constraints: const BoxConstraints(maxWidth: 136),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.onPrimary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelCaps(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextAction(AdminMainController main, {required bool compact}) {
    return Semantics(
      button: true,
      label: 'Vazifalar'.tr,
      child: Pressable(
        onTap: () => main.changeTab(AdminMainController.tasksTab),
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onPrimary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_rounded,
                color: AppColors.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vazifalar'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${controller.openTaskCount} ${'Ochiq'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onPrimary.withValues(alpha: 0.82),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.onPrimary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(color: AppColors.onErrorContainer),
            ),
          ),
          TextButton(onPressed: controller.loadData, child: Text('Qayta'.tr)),
        ],
      ),
    );
  }

  /// Ochiq → jarayonda → yakunlangan oqimi. Har yo'lak amaldagi vazifalar
  /// sahifasiga olib boradi; shu sabab bu yer faqat statik diagramma emas.
  Widget _buildTaskFlow(AdminMainController main) {
    return AdminWorkspaceSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _workspaceHeading(
            title: 'Vazifalar'.tr,
            onTap: () => main.changeTab(AdminMainController.tasksTab),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 380;
              final lanes = [
                _TaskLane(
                  label: 'Ochiq'.tr,
                  count: controller.openTaskCount,
                  icon: Icons.assignment_late_outlined,
                  color: AppColors.primary,
                  onTap: () => main.changeTab(AdminMainController.tasksTab),
                ),
                _TaskLane(
                  label: 'Jarayonda'.tr,
                  count: controller.inProgressTaskCount,
                  icon: Icons.pending_rounded,
                  color: AppColors.statusInProgress,
                  onTap: () => main.changeTab(AdminMainController.tasksTab),
                ),
                _TaskLane(
                  label: 'Yakunlangan'.tr,
                  count: controller.completedTaskCount,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  onTap: () => main.changeTab(AdminMainController.tasksTab),
                ),
              ];
              if (vertical) {
                return Column(
                  children: [
                    for (var i = 0; i < lanes.length; i++) ...[
                      lanes[i],
                      if (i < lanes.length - 1) const SizedBox(height: 7),
                    ],
                  ],
                );
              }
              // IntrinsicHeight + stretch: yorliq bir kartada 2 qatorga
              // o'tsa ham UCHALA karta BIR XIL balandlikda turadi —
              // "biri katta, biri kichik" nosimmetriya bo'lmaydi
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < lanes.length; i++) ...[
                      Expanded(child: lanes[i]),
                      if (i < lanes.length - 1) const SizedBox(width: 7),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatusWorkspace() {
    final total = controller.totalRooms;
    return AdminWorkspaceSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _workspaceHeading(
            title: 'Xonalar holati'.tr,
            onTap: () => Get.toNamed('/occupied-rooms'),
          ),
          const SizedBox(height: 11),
          if (total == 0)
            Text(
              'Ma\'lumot yo\'q'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            )
          else ...[
            _buildSegmentedBar(total),
            const SizedBox(height: 12),
            for (final status in RoomModel.statuses)
              if (controller.statusCount(status) > 0)
                _roomStatusRow(status, total),
          ],
        ],
      ),
    );
  }

  Widget _workspaceHeading({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h2(),
          ),
        ),
        Tooltip(
          message: title,
          child: Pressable(
            haptic: false,
            onTap: onTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedBar(int total) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.count,
      curve: AppMotion.emphasized,
      builder: (context, progress, child) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(widthFactor: progress, child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 9,
          child: Row(
            children: RoomModel.statuses
                .where((status) => controller.statusCount(status) > 0)
                .map(
                  (status) => Expanded(
                    flex: controller.statusCount(status),
                    child: ColoredBox(color: roomStatusColor(status)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _roomStatusRow(String status, int total) {
    final count = controller.statusCount(status);
    final color = roomStatusColor(status);
    final percent = (count / total * 100).round();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              RoomModel.statusLabel(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(),
            ),
          ),
          Text(
            '$percent%',
            style: AppTextStyles.bodyMd(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMd(
                color: color,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTaskQueue(AdminMainController main) {
    final items = controller.recentActiveTasks;
    return AdminWorkspaceSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _workspaceHeading(
            title: 'Faol vazifalar'.tr,
            onTap: () => main.changeTab(AdminMainController.tasksTab),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'Faol vazifalar yo\'q'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.48),
              ),
              itemBuilder: (context, index) => _ActiveTaskRow(
                task: items[index],
                onTap: () => main.changeTab(AdminMainController.tasksTab),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskLane extends StatelessWidget {
  const _TaskLane({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $count',
      child: Pressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth < 120;
              final text = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: AppTextStyles.h2(
                      color: color,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    label,
                    maxLines: horizontal ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
              if (!horizontal) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 19),
                    text,
                  ],
                );
              }
              return Row(
                children: [
                  Icon(icon, color: color, size: 19),
                  const SizedBox(width: 9),
                  Expanded(child: text),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActiveTaskRow extends StatelessWidget {
  const _ActiveTaskRow({required this.task, required this.onTap});

  final HkTaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = taskStatusColor(task.status);
    return Semantics(
      button: true,
      label:
          '${'Xona'.tr} ${task.roomNumber}: ${HkTaskModel.statusLabel(task.status)}',
      child: Pressable(
        haptic: false,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 300;
            final leading = Container(
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                task.roomNumber.isEmpty ? '—' : task.roomNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd(
                  color: AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            );
            final copy = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HkTaskModel.typeLabel(task.taskType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.assigneeName.isNotEmpty)
                  Text(
                    task.assigneeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            );
            final status = AdminChip(
              label: HkTaskModel.statusLabel(task.status),
              color: statusColor,
            );

            if (narrow) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        leading,
                        const SizedBox(width: 9),
                        Expanded(child: copy),
                      ],
                    ),
                    const SizedBox(height: 7),
                    status,
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 10),
                  Expanded(child: copy),
                  const SizedBox(width: 8),
                  Flexible(child: status),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
