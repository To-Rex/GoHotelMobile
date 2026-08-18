import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/room_model.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_rooms_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminRoomsPage extends GetView<AdminRoomsController> {
  const AdminRoomsPage({super.key});

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
              title: 'Xonalar holati'.tr,
              subtitle: 'Qavatlar bo\'yicha ko\'rinish'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildSummary()),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Obx(() => _buildContent(main)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RoomModel.statuses.map((status) {
            final count = controller.statusCount(status);
            if (count == 0) return const SizedBox.shrink();
            return AdminChip(
              label: '${RoomModel.statusLabel(status)} • $count',
              color: roomStatusColor(status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(AdminMainController main) {
    if (controller.isLoading.value && controller.rooms.isEmpty) {
      return const AdminSkeletonList(count: 4, height: 100);
    }

    if (controller.rooms.isEmpty) {
      // Tarmoq xatosi bo'sh ro'yxatdan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: error == null
              ? Icons.meeting_room_outlined
              : Icons.wifi_off_rounded,
          message: error ?? 'Xonalar topilmadi'.tr,
          actionLabel: error == null ? null : 'Qayta urinish'.tr,
          onAction: error == null ? null : controller.loadData,
        ),
      );
    }

    final canUpdate = main.can('room.update');
    final groups = controller.groupedByFloor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          FadeSlideIn(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 6),
              child: Text(groups[i].key, style: AppTextStyles.h2()),
            ),
          ),
          FadeSlideIn(
            index: i,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: groups[i].value
                  .map(
                    (room) => _RoomTile(
                      room: room,
                      onTap: canUpdate ? () => _showStatusSheet(room) : null,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  void _showStatusSheet(RoomModel room) {
    // Sheet balandligi cheklanadi va ichi SCROLL bo'ladi — kalta/landshaft
    // ekranda yoki katta shriftda oxirgi holatlar bosib bo'lmas edi
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              '${'Xona'.tr} ${room.roomNumber} — ${'Holatni o\'zgartirish'.tr}',
              style: AppTextStyles.h2(),
            ),
            const SizedBox(height: 12),
            ...RoomModel.statuses.map(
              (status) => ListTile(
                leading: Icon(
                  status == room.currentStatus
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: roomStatusColor(status),
                ),
                title: Text(
                  RoomModel.statusLabel(status),
                  style: AppTextStyles.bodyLg(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: () {
                  Get.back();
                  if (status != room.currentStatus) {
                    controller.changeStatus(room, status);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _RoomTile extends StatelessWidget {
  final RoomModel room;
  final VoidCallback? onTap;

  const _RoomTile({required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = roomStatusColor(room.currentStatus);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        // Holat o'zgarganda rang yumshoq almashadi.
        duration: AppMotion.base,
        curve: AppMotion.enter,
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              room.roomNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLg(color: AppColors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              RoomModel.statusLabel(room.currentStatus),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelCaps(color: color, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
