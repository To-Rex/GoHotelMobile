import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../data/models/task_model.dart';
import '../animations/app_animations.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onReport;
  final VoidCallback? onProblemReport;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStart,
    this.onFinish,
    this.onReport,
    this.onProblemReport,
  });

  Color get _accentColor => task.isUrgent
      ? AppColors.error
      : switch (task.status) {
          TaskStatus.inProgress => AppColors.statusInProgress,
          TaskStatus.completed => AppColors.success,
          TaskStatus.pending => AppColors.outlineVariant,
        };

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: task.isUrgent
              ? Border.all(color: AppColors.error.withValues(alpha: 0.35))
              : null,
          boxShadow: task.isUrgent
              ? AppShadows.glow(AppColors.error, alpha: 0.12)
              : AppShadows.soft,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          task.roomNumber,
                          style: AppTextStyles.display(
                            fontSize: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(),
                        const Spacer(),
                        if (task.isUrgent)
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${task.floor} • ${task.roomType}',
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (task.guest != null || task.deadline != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (task.guest != null)
                            _metaChip(
                              Icons.person_outline_rounded,
                              '${task.guest} (${task.guestStatus})',
                            ),
                          if (task.deadline != null)
                            _metaChip(Icons.schedule_rounded, task.deadline!),
                        ],
                      ),
                    ],
                    if (task.status == TaskStatus.inProgress) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedProgressBar(
                              value: task.progress / 100,
                              height: 7,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${task.progress}%',
                            style: AppTextStyles.labelCaps(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.isUrgent && task.note != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.priority_high_rounded,
                              size: 16,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task.note!,
                                style: AppTextStyles.bodyMd(
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (task.status == TaskStatus.pending ||
                        task.status == TaskStatus.inProgress ||
                        task.isUrgent) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (task.status == TaskStatus.pending)
                            _actionButton(
                              task.isUrgent ? 'Bajarish'.tr : 'Boshlash'.tr,
                              AppColors.primaryContainer,
                              AppColors.onPrimary,
                              Icons.play_arrow_rounded,
                              onStart ?? onTap,
                              glow: true,
                            ),
                          if (task.status == TaskStatus.inProgress) ...[
                            _actionButton(
                              'Yakunlash'.tr,
                              AppColors.primaryContainer,
                              AppColors.onPrimary,
                              Icons.check_circle_rounded,
                              onFinish,
                              glow: true,
                            ),
                            _actionButton(
                              'Hisobot'.tr,
                              AppColors.surfaceContainer,
                              AppColors.primary,
                              Icons.photo_camera_rounded,
                              onReport,
                            ),
                            _actionButton(
                              'Muammo'.tr,
                              AppColors.surfaceContainer,
                              AppColors.error,
                              Icons.report_problem_outlined,
                              onProblemReport,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.bodyMd(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;

    switch (task.status) {
      case TaskStatus.inProgress:
        bgColor = AppColors.statusInProgressBg;
        textColor = AppColors.statusInProgress;
        text = 'Jarayonda'.tr;
        break;
      case TaskStatus.completed:
        bgColor = AppColors.statusCleanedBg;
        textColor = AppColors.statusCleaned;
        text = 'Tozalangan'.tr;
        icon = Icons.check_circle_rounded;
        break;
      case TaskStatus.pending:
        if (task.isUrgent) {
          bgColor = AppColors.errorContainer;
          textColor = AppColors.onErrorContainer;
          text = 'Shoshilinch'.tr;
        } else {
          bgColor = AppColors.statusPendingBg;
          textColor = AppColors.statusPending;
          text = 'Tozalanishi kerak'.tr;
        }
        break;
    }

    return AnimatedContainer(
      duration: AppMotion.base,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(text, style: AppTextStyles.statusBadge(color: textColor)),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
    VoidCallback? onPressed, {
    bool glow = false,
  }) {
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: glow
              ? AppShadows.glow(AppColors.primary, alpha: 0.25)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.statusBadge(color: textColor)),
          ],
        ),
      ),
    );
  }
}
