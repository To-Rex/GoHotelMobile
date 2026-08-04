import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/occupied_room_model.dart';
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
              child: _RoomCard(
                room: entry.value,
                minutesLeft: controller.minutesLeft(entry.value),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final OccupiedRoomModel room;
  final int minutesLeft;

  const _RoomCard({required this.room, required this.minutesLeft});

  @override
  Widget build(BuildContext context) {
    final overdue = minutesLeft < 0;
    final soon = !overdue && minutesLeft <= 60;

    final Color timeColor;
    final Color timeBg;
    if (overdue) {
      timeColor = AppColors.error;
      timeBg = AppColors.errorContainer;
    } else if (soon) {
      timeColor = AppColors.statusInProgress;
      timeBg = AppColors.statusInProgressBg;
    } else {
      timeColor = AppColors.statusCleaned;
      timeBg = AppColors.statusCleanedBg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'XONA'.tr,
                      style: AppTextStyles.labelCaps(
                        color: AppColors.primary,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.roomNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.guestName.isEmpty ? 'Mehmon'.tr : room.guestName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLg(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip(
                          room.isReserved ? 'Bron'.tr : 'Band'.tr,
                          room.isReserved
                              ? AppColors.statusPending
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          room.isHourly ? 'Soatlik'.tr : 'Kunlik'.tr,
                          AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${'Chiqish'.tr}: ${room.checkoutLabel}',
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: timeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  OccupiedRoomModel.formatRemaining(minutesLeft),
                  style: AppTextStyles.labelCaps(color: timeColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.labelCaps(color: color)),
    );
  }
}
