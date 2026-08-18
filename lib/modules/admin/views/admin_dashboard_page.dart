import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/hk_task_model.dart';
import '../../../data/models/room_model.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_main_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

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
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.rooms.isEmpty &&
                        controller.tasks.isEmpty) {
                      return const AdminSkeletonList(count: 5);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(index: 1, child: _buildHero()),
                        const SizedBox(height: 16),
                        FadeSlideIn(index: 2, child: _buildTaskStats(main)),
                        const SizedBox(height: 16),
                        FadeSlideIn(index: 3, child: _buildOccupiedRoomsCard()),
                        const SizedBox(height: 24),
                        FadeSlideIn(index: 4, child: _buildRoomBreakdown()),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          index: 5,
                          child: _buildRecentTasksHeader(main),
                        ),
                        const SizedBox(height: 12),
                        _buildRecentTasks(main),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradientli hero: bandlik halqasi va asosiy raqamlar bir qarashda.
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.glow(AppColors.primary, alpha: 0.3),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UMUMIY HOLAT'.tr,
                    style: AppTextStyles.labelCaps(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Xush kelibsiz!'.tr,
                    style: AppTextStyles.h1(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _heroChip(
                        Icons.meeting_room_rounded,
                        '${controller.totalRooms} ${'ta xona'.tr}',
                      ),
                      _heroChip(
                        Icons.check_circle_rounded,
                        '${controller.statusCount('AVAILABLE')} ${'bo\'sh'.tr}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedProgressRing(
                    value: controller.occupancy,
                    size: 72,
                    strokeWidth: 7,
                    textStyle: AppTextStyles.h2(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Bandlik'.tr,
                    style: AppTextStyles.labelCaps(color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelCaps(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStats(AdminMainController main) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Ochiq'.tr,
              count: controller.openTaskCount,
              icon: Icons.assignment_late_outlined,
              iconColor: AppColors.primary,
              onTap: () => main.changeTab(AdminMainController.tasksTab),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Jarayonda'.tr,
              count: controller.inProgressTaskCount,
              icon: Icons.pending_rounded,
              iconColor: AppColors.statusInProgress,
              onTap: () => main.changeTab(AdminMainController.tasksTab),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Yakunlangan'.tr,
              count: controller.completedTaskCount,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.success,
              onTap: () => main.changeTab(AdminMainController.tasksTab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupiedRoomsCard() {
    return Pressable(
      onTap: () => Get.toNamed('/occupied-rooms'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.meeting_room_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Band xonalar'.tr, style: AppTextStyles.bodyLg()),
                  const SizedBox(height: 2),
                  Text(
                    'Xonalar qachon bo\'shashini ko\'ring'.tr,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Xonalar holati — jonli segmentli diagramma va legenda.
  Widget _buildRoomBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Obx(() {
        final total = controller.totalRooms;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('XONALAR HOLATI'.tr, style: AppTextStyles.labelCaps()),
            const SizedBox(height: 14),
            if (total == 0)
              Text(
                'Ma\'lumot yo\'q'.tr,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              )
            else ...[
              _buildSegmentedBar(total),
              const SizedBox(height: 14),
              Column(
                children: RoomModel.statuses.map((status) {
                  final count = controller.statusCount(status);
                  if (count == 0) return const SizedBox.shrink();
                  final color = roomStatusColor(status);
                  final pct = (count / total * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            RoomModel.statusLabel(status),
                            style: AppTextStyles.bodyMd(),
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: AppTextStyles.labelCaps(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedCount(
                          value: count,
                          style: AppTextStyles.bodyLg(color: color),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildSegmentedBar(int total) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.count,
      curve: AppMotion.emphasized,
      builder: (context, t, child) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(widthFactor: t, child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 10,
          child: Row(
            children: RoomModel.statuses
                .where((s) => controller.statusCount(s) > 0)
                .map(
                  (s) => Expanded(
                    flex: controller.statusCount(s),
                    child: Container(color: roomStatusColor(s)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTasksHeader(AdminMainController main) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Faol vazifalar'.tr, style: AppTextStyles.h2()),
        Pressable(
          onTap: () => main.changeTab(AdminMainController.tasksTab),
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
                  'Hammasi'.tr,
                  style: AppTextStyles.statusBadge(color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTasks(AdminMainController main) {
    return Obx(() {
      final items = controller.recentActiveTasks;
      if (items.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Faol vazifalar yo\'q'.tr,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        );
      }
      return Column(
        children: items
            .map(
              (task) => Pressable(
                onTap: () => main.changeTab(AdminMainController.tasksTab),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      // Tor ekranda uzun xona raqami qatordan chiqib ketmasin
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          task.roomNumber.isEmpty ? '—' : task.roomNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h2(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              HkTaskModel.typeLabel(task.taskType),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMd(),
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
                        ),
                      ),
                      Flexible(
                        child: AdminChip(
                          label: HkTaskModel.statusLabel(task.status),
                          color: taskStatusColor(task.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}
