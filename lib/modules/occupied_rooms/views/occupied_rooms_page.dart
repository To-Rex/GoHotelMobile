import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/occupied_room_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../controllers/occupied_rooms_controller.dart';

class OccupiedRoomsPage extends GetView<OccupiedRoomsController> {
  const OccupiedRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Band xonalar'.tr,
              subtitle: 'Xonalar qachon bo\'shaydi'.tr,
              showBackButton: true,
              showAvatar: false,
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildStatsRow()),
            const SizedBox(height: 12),
            FadeSlideIn(index: 2, child: _buildReservedToggle()),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadRooms,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Obx(() => _buildContent()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Jami band'.tr,
                count: controller.totalCount,
                icon: Icons.meeting_room_rounded,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: '1 soatgacha'.tr,
                count: controller.soonCount,
                icon: Icons.schedule_rounded,
                iconColor: AppColors.statusInProgress,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Kechikkan'.tr,
                count: controller.overdueCount,
                icon: Icons.running_with_errors_rounded,
                iconColor: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservedToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bron qilinganlarni ham ko\'rsatish'.tr,
                  style: AppTextStyles.bodyMd(),
                ),
              ),
              Switch(
                value: controller.includeReserved.value,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => controller.toggleReserved(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.rooms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (controller.rooms.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: Icons.night_shelter_rounded,
          message: 'Hozircha band xonalar yo\'q'.tr,
        ),
      );
    }

    return Column(
      children: controller.rooms
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideIn(
              index: entry.key,
              child: OccupiedRoomCard(
                room: entry.value,
                minutesLeft: controller.minutesLeft(entry.value),
              ),
            ),
          )
          .toList(),
    );
  }
}
