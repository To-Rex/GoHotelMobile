import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../data/models/occupied_room_model.dart';

/// Band xona kartochkasi — Home va "Band xonalar" sahifalarida bir xil
/// ko'rinish uchun umumiy vidjet. [minutesLeft] jonli qoldiq daqiqa
/// (kechikkan bo'lsa manfiy) — hisoblash controller'da qiladi.
class OccupiedRoomCard extends StatelessWidget {
  final OccupiedRoomModel room;
  final int minutesLeft;

  const OccupiedRoomCard({
    super.key,
    required this.room,
    required this.minutesLeft,
  });

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
