import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
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
        child: Column(
          children: [
            const AppHeader(
              title: 'GoHotel Service',
              showAvatar: true,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadNotifications,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      Obx(
                        () => controller.notifications.isEmpty
                            ? const EmptyState(
                                icon: Icons.notifications_active_outlined,
                                message:
                                    'Barcha yangiliklardan xabardor bo\'ling',
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YANGILANISHLAR', style: AppTextStyles.labelCaps()),
            const SizedBox(height: 2),
            Text('Bildirishnomalar', style: AppTextStyles.h2()),
          ],
        ),
        Obx(
          () => Flexible(
            child: GestureDetector(
              onTap: controller.unreadCount > 0
                  ? controller.markAllAsRead
                  : null,
              child: Text(
                'Hammasini o\'qilgan deb belgilash',
                style: AppTextStyles.bodyMd(
                  color: controller.unreadCount > 0
                      ? AppColors.primary
                      : AppColors.outline,
                ),
                textAlign: TextAlign.right,
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
        children: controller.notifications.map((notif) {
          return _NotificationCard(
            notification: notif,
            onMarkRead: () => controller.markAsRead(notif.id),
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkRead;

  const _NotificationCard({
    required this.notification,
    required this.onMarkRead,
  });

  Color get _borderColor {
    switch (notification.type) {
      case NotificationType.critical:
        return AppColors.error;
      case NotificationType.newTask:
        return AppColors.primary;
      case NotificationType.problemAccepted:
        return AppColors.secondary;
      case NotificationType.inventory:
        return AppColors.tertiary;
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
        return AppColors.secondaryContainer.withValues(alpha: 0.2);
      case NotificationType.inventory:
        return AppColors.tertiaryContainer.withValues(alpha: 0.2);
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
        return AppColors.secondary;
      case NotificationType.inventory:
        return AppColors.tertiary;
      case NotificationType.system:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.critical:
        return Icons.emergency;
      case NotificationType.newTask:
        return Icons.assignment_add;
      case NotificationType.problemAccepted:
        return Icons.check_circle;
      case NotificationType.inventory:
        return Icons.inventory_2;
      case NotificationType.system:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = notification.type == NotificationType.problemAccepted
        ? 0.8
        : notification.type == NotificationType.system
            ? 0.7
            : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onMarkRead,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surfaceContainerLowest
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border(left: BorderSide(color: _borderColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 8),
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
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Xona ${notification.roomNumber}',
                                style: AppTextStyles.labelCaps(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (notification.hasActions) ...[
                            _buildActionButton(
                              'BORISH',
                              AppColors.primaryContainer,
                              AppColors.onPrimary,
                            ),
                            _buildActionButton(
                              'RAD ETISH',
                              AppColors.surfaceContainer,
                              AppColors.onSurfaceVariant,
                            ),
                          ],
                        ],
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

  Widget _buildActionButton(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.labelCaps(color: textColor)),
    );
  }
}
