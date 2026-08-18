import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/reservation_model.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_reservations_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminReservationsPage extends GetView<AdminReservationsController> {
  const AdminReservationsPage({super.key});

  static const _filters = [
    ('', 'Hammasi'),
    ('PENDING', 'Kutilmoqda'),
    ('CONFIRMED', 'Tasdiqlangan'),
    ('CHECKED_IN', 'Yashamoqda'),
    ('CHECKED_OUT', 'Chiqib ketgan'),
    ('CANCELLED', 'Bekor qilingan'),
  ];

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
              title: 'Bronlar'.tr,
              subtitle: 'Barcha bronlar va mehmonlar'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildFilterChips()),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: Obx(() => _buildContent(main)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selected = controller.selectedStatus.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final (value, label) = _filters[index];
            final active = selected == value;
            return Pressable(
              onTap: () => controller.changeFilter(value),
              child: AnimatedContainer(
                duration: AppMotion.base,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  label.tr,
                  style: AppTextStyles.statusBadge(
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildContent(AdminMainController main) {
    if (controller.isLoading.value && controller.reservations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: const [AdminSkeletonList(count: 5, height: 120)],
      );
    }

    if (controller.reservations.isEmpty) {
      // Tarmoq xatosi bo'sh ro'yxatdan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
        children: [
          EmptyState(
            icon: error == null
                ? Icons.event_note_outlined
                : Icons.wifi_off_rounded,
            message: error ?? 'Bronlar topilmadi'.tr,
            actionLabel: error == null ? null : 'Qayta urinish'.tr,
            onAction: error == null ? null : controller.loadData,
          ),
        ],
      );
    }

    final canUpdate = main.can('reservation.update');
    final canCancel = main.can('reservation.cancel');
    final items = controller.reservations;
    // Lazy ro'yxat: faqat ko'rinayotgan kartalar quriladi (500 tagacha yozuv).
    // Stagger indeksi 12 da to'xtaydi — pastdagi kartalar soatlab "ko'rinmay"
    // qolmasligi uchun.
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final r = items[i];
        return FadeSlideIn(
          index: i.clamp(0, 12),
          child: Obx(
            () => _ReservationCard(
              reservation: r,
              roomNumber: controller.roomNumberOf(r),
              guestName: controller.guestNameOf(r),
              busy: controller.isBusy(r.id),
              canUpdate: canUpdate,
              canCancel: canCancel,
              onCheckIn: () => controller.checkIn(r),
              onCheckOut: () => controller.checkOut(r),
              onCancel: () => _confirmCancel(r),
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(ReservationModel reservation) {
    final reasonController = TextEditingController();
    // Dialog yopilgach controller albatta bo'shatiladi (xotira oqmasin)
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Bronni bekor qilish?'.tr, style: AppTextStyles.h2()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'Xona'.tr} ${controller.roomNumberOf(reservation)} • '
              '${reservation.checkInDate} → ${reservation.checkOutDate}',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: AppTextStyles.bodyMd(),
              decoration: InputDecoration(
                hintText: 'Sabab (ixtiyoriy)'.tr,
                hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Yo\'q'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              Get.back();
              controller.cancel(reservation, reason);
            },
            child: Text(
              'Ha, bekor qilish'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.error),
            ),
          ),
        ],
      ),
    ).then((_) => reasonController.dispose());
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final String roomNumber;
  final String guestName;
  final bool canUpdate;
  final bool canCancel;
  // Amal bajarilmoqda — tugmalar bloklanadi (dublikat so'rov oldini oladi)
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;

  const _ReservationCard({
    required this.reservation,
    required this.roomNumber,
    required this.guestName,
    required this.canUpdate,
    required this.canCancel,
    this.busy = false,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = reservationStatusColor(reservation.status);
    final paid = reservation.paymentStatus == 'PAID';
    return Container(
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
              child: Container(width: 4, color: statusColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tor ekranda uzun xona raqami kartadan chiqib ketmasin
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 96),
                        child: Text(
                          roomNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(
                            fontSize: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guestName.isEmpty ? 'Mehmon'.tr : guestName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLg(),
                            ),
                            Text(
                              // Soatlik bronda kun + vaqt oralig'i ko'rsatiladi
                              reservation.periodLabel,
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
                          label: ReservationModel.statusLabel(
                            reservation.status,
                          ),
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AdminChip(
                        label: reservation.bookingType == 'HOURLY'
                            ? 'Soatlik'.tr
                            : 'Kunlik'.tr,
                        color: AppColors.secondary,
                      ),
                      AdminChip(
                        label: ReservationModel.paymentLabel(
                          reservation.paymentStatus,
                        ),
                        color: paid
                            ? AppColors.statusCleaned
                            : AppColors.statusInProgress,
                      ),
                      Text(
                        '${formatMoney(reservation.paidAmount)} / ${formatMoney(reservation.totalAmount)}',
                        style: AppTextStyles.bodyMd(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if ((canUpdate &&
                          (reservation.canCheckIn ||
                              reservation.canCheckOut)) ||
                      (canCancel && reservation.isActive)) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (canUpdate && reservation.canCheckIn)
                          _actionButton(
                            'Kirish (check-in)'.tr,
                            AppColors.primaryContainer,
                            AppColors.onPrimary,
                            Icons.login_rounded,
                            onCheckIn,
                          ),
                        if (canUpdate && reservation.canCheckOut)
                          _actionButton(
                            'Chiqish (check-out)'.tr,
                            AppColors.primaryContainer,
                            AppColors.onPrimary,
                            Icons.logout_rounded,
                            onCheckOut,
                          ),
                        if (canCancel && reservation.isActive)
                          _actionButton(
                            'Bekor qilish'.tr,
                            AppColors.surfaceContainer,
                            AppColors.error,
                            Icons.close_rounded,
                            onCancel,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
    VoidCallback onPressed,
  ) {
    // busy paytida tugma bloklanadi va ikonka o'rnida spinner ko'rinadi
    return Pressable(
      onTap: busy ? null : onPressed,
      child: Opacity(
        opacity: busy ? 0.55 : 1,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              else
                Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.statusBadge(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
