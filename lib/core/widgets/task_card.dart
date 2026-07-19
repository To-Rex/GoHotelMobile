import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../data/models/task_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: task.isUrgent
              ? AppColors.errorContainer.withValues(alpha: 0.5)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            left: BorderSide(
              color: task.isUrgent
                  ? AppColors.error
                  : task.status == TaskStatus.inProgress
                      ? AppColors.primary
                      : AppColors.outlineVariant,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        task.roomNumber,
                        style: AppTextStyles.h1(color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(),
                    ],
                  ),
                  if (task.isUrgent)
                    const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${task.floor} • ${task.roomType}',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              if (task.guest != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${task.guest} (${task.guestStatus})',
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if (task.deadline != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      task.deadline!,
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if (task.status == TaskStatus.inProgress) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progress / 100,
                    backgroundColor: AppColors.surfaceContainer,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.progress}%',
                  style: AppTextStyles.labelCaps(color: AppColors.primary),
                ),
              ],
              if (task.isUrgent) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: AppColors.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.note ?? '',
                        style: AppTextStyles.bodyMd(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
              if (task.status == TaskStatus.pending || task.status == TaskStatus.inProgress || task.isUrgent)
                ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (task.status == TaskStatus.pending)
                        _buildActionButton(
                          task.isUrgent ? 'Bajarish' : 'Boshlash',
                          AppColors.primaryContainer,
                          AppColors.onPrimary,
                          Icons.play_arrow,
                          onStart ?? onTap,
                        ),
                      if (task.status == TaskStatus.inProgress) ...[
                        _buildActionButton(
                          'Yakunlash',
                          AppColors.primaryContainer,
                          AppColors.onPrimary,
                          Icons.check_circle,
                          onFinish,
                        ),
                        _buildActionButton(
                          'Hisobot',
                          AppColors.surfaceContainer,
                          AppColors.primary,
                          Icons.photo_camera,
                          onReport,
                        ),
                        _buildActionButton(
                          'Muammo',
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
        text = 'Jarayonda';
        break;
      case TaskStatus.completed:
        bgColor = AppColors.statusCleanedBg;
        textColor = AppColors.statusCleaned;
        text = 'Tozalangan';
        icon = Icons.check_circle;
        break;
      case TaskStatus.pending:
        if (task.isUrgent) {
          bgColor = AppColors.errorContainer;
          textColor = AppColors.onErrorContainer;
          text = 'Shoshilinch';
        } else {
          bgColor = AppColors.statusPendingBg;
          textColor = AppColors.statusPending;
          text = 'Tozalanishi kerak';
        }
        break;
    }

    return Container(
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

  Widget _buildActionButton(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
