import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(title: 'GoHotel Service', showAvatar: true),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadNotifications,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(index: 1, child: _buildHeader()),
                      const SizedBox(height: 16),
                      Obx(
                        () => controller.notifications.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: EmptyState(
                                  icon: Icons.notifications_active_outlined,
                                  message:
                                      'Barcha yangiliklardan xabardor bo\'ling'
                                          .tr,
                                ),
                              )
                            : _buildNotificationsList(),
                      ),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YANGILANISHLAR'.tr, style: AppTextStyles.labelCaps()),
            const SizedBox(height: 2),
            Text('Bildirishnomalar'.tr, style: AppTextStyles.h2()),
          ],
        ),
        Obx(
          () => Flexible(
            child: Pressable(
              onTap: controller.unreadCount > 0
                  ? controller.markAllAsRead
                  : null,
              child: AnimatedOpacity(
                duration: AppMotion.base,
                opacity: controller.unreadCount > 0 ? 1 : 0.45,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'O\'qildi deb belgilash'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.statusBadge(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    return Obx(
      () => Column(
        children: controller.notifications
            .asMap()
            .entries
            .map(
              (entry) => FadeSlideIn(
                index: 2 + entry.key,
                child: _NotificationCard(
                  notification: entry.value,
                  onMarkRead: () => controller.markAsRead(entry.value.id),
                  onGo: () => controller.goToTarget(entry.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkRead;
  final VoidCallback onGo;

  const _NotificationCard({
    required this.notification,
    required this.onMarkRead,
    required this.onGo,
  });

  Color get _accentColor {
    switch (notification.type) {
      case NotificationType.critical:
        return AppColors.error;
      case NotificationType.newTask:
        return AppColors.primary;
      case NotificationType.problemAccepted:
        return AppColors.success;
      case NotificationType.inventory:
        return AppColors.tertiaryContainer;
      case NotificationType.system:
        return AppColors.outlineVariant;
    }
  }

  Color get _iconBgColor {
    switch (notification.type) {
      case NotificationType.critical:
        return AppColors.errorContainer;
      case NotificationType.newTask:
        return AppColors.surfaceContainer;
      case NotificationType.problemAccepted:
        return AppColors.statusCleanedBg;
      case NotificationType.inventory:
        return AppColors.tertiaryContainer.withValues(alpha: 0.15);
      case NotificationType.system:
        return AppColors.surfaceContainerHigh;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.critical:
        return AppColors.error;
      case NotificationType.newTask:
        return AppColors.primary;
      case NotificationType.problemAccepted:
        return AppColors.success;
      case NotificationType.inventory:
        return AppColors.tertiary;
      case NotificationType.system:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.critical:
        return Icons.emergency_rounded;
      case NotificationType.newTask:
        return Icons.assignment_add;
      case NotificationType.problemAccepted:
        return Icons.check_circle_rounded;
      case NotificationType.inventory:
        return Icons.inventory_2_rounded;
      case NotificationType.system:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted =
        notification.type == NotificationType.problemAccepted ||
        notification.type == NotificationType.system;

    return AnimatedOpacity(
      duration: AppMotion.base,
      opacity: muted ? 0.75 : 1,
      child: Pressable(
        onTap: onMarkRead,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 4, color: _accentColor),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon, color: _iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.bodyLg(),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Text(
                                  notification.timeAgo,
                                  style: AppTextStyles.labelCaps(
                                    color: AppColors.outline,
                                  ),
                                ),
                                if (notification.roomNumber != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${'Xona'.tr} ${notification.roomNumber}',
                                      style: AppTextStyles.labelCaps(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                if (notification.hasActions) _buildGoButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoButton() {
    return Pressable(
      onTap: onGo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.glow(AppColors.primary, alpha: 0.25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BORISH'.tr,
              style: AppTextStyles.labelCaps(color: AppColors.onPrimary),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
