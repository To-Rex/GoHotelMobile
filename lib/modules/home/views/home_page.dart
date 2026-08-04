import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/occupied_room_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../occupied_rooms/controllers/occupied_rooms_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_controller.dart';

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
            AppHeader(title: 'GoHotel Service', subtitle: 'Xodim profili'.tr),
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
                      const SizedBox(height: 16),
                      FadeSlideIn(index: 3, child: _buildTasksNavCard()),
                      const SizedBox(height: 28),
                      FadeSlideIn(index: 4, child: _buildRoomsHeader()),
                      const SizedBox(height: 14),
                      _buildRoomsList(),
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
                Text(
                  'BUGUNGI SMENA'.tr,
                  style: AppTextStyles.labelCaps(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text('Xush kelibsiz!'.tr, style: AppTextStyles.h1()),
                const SizedBox(height: 4),
                Text(
                  'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.'.tr,
                  style: AppTextStyles.bodyMd(
                    color: AppColors.onSurfaceVariant,
                  ),
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
              'Bajarilish'.tr,
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
              title: 'Yakunlandi'.tr,
              count: controller.completedTasks.value,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Kutilmoqda'.tr,
              count: controller.pendingTasks.value,
              icon: Icons.pending_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Muammo'.tr,
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

  /// Vazifalar tab'iga tez o'tish kartasi — avval "Band xonalar" shu shaklda
  /// edi; endi ro'yxat Home'da bo'lgani uchun karta vazifalarga yo'naltiradi.
  Widget _buildTasksNavCard() {
    return Pressable(
      onTap: () => Get.find<MainController>().changeTab(1),
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
                Icons.cleaning_services_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bugungi vazifalar'.tr, style: AppTextStyles.bodyLg()),
                  const SizedBox(height: 2),
                  Text(
                    'Barcha vazifalarni ko\'rish'.tr,
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

  Widget _buildRoomsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Band xonalar'.tr, style: AppTextStyles.h2()),
        Pressable(
          onTap: () => Get.toNamed('/occupied-rooms'),
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

  Widget _buildRoomsList() {
    final roomsController = Get.find<OccupiedRoomsController>();
    return Obx(() {
      if (roomsController.isLoading.value && roomsController.rooms.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (roomsController.rooms.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: EmptyState(
            icon: Icons.night_shelter_rounded,
            message: 'Hozircha band xonalar yo\'q'.tr,
          ),
        );
      }

      return Column(
        children: roomsController.rooms
            .asMap()
            .entries
            .map(
              (entry) => FadeSlideIn(
                index: 5 + entry.key,
                child: OccupiedRoomCard(
                  room: entry.value,
                  minutesLeft: roomsController.minutesLeft(entry.value),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}
