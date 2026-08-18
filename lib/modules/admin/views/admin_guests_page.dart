import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/admin_guests_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminGuestsPage extends GetView<AdminGuestsController> {
  const AdminGuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppHeader(
            title: 'Mehmonlar'.tr,
            subtitle: 'Mehmonlar bazasi'.tr,
            showAvatar: false,
            leading: const DrawerMenuButton(),
          ),
          const SizedBox(height: 4),
          FadeSlideIn(index: 1, child: _buildSearch()),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadGuests,
              child: Obx(() => _buildContent()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => controller.query.value = v,
        style: AppTextStyles.bodyMd(),
        decoration: InputDecoration(
          hintText: 'Ism yoki telefon bo\'yicha qidirish'.tr,
          hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.guests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: const [AdminSkeletonList(count: 6, height: 76)],
      );
    }

    final items = controller.filtered;
    if (items.isEmpty) {
      // Tarmoq xatosi bo'sh natijadan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
        children: [
          EmptyState(
            icon: error == null
                ? Icons.person_search_outlined
                : Icons.wifi_off_rounded,
            message: error ?? 'Mehmonlar topilmadi'.tr,
            actionLabel: error == null ? null : 'Qayta urinish'.tr,
            onAction: error == null ? null : controller.loadGuests,
          ),
        ],
      );
    }

    // Lazy ro'yxat — faqat ko'rinayotgan qatorlar quriladi (1000 tagacha yozuv)
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: items.length,
      itemBuilder: (context, i) => _guestRow(items[i], i),
    );
  }

  Widget _guestRow(dynamic guest, int index) {
    final entry = MapEntry(index, guest);
    return FadeSlideIn(
              index: entry.key.clamp(0, 12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.name.isEmpty
                                ? 'Mehmon'.tr
                                : entry.value.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyLg(),
                          ),
                          if (entry.value.phone?.isNotEmpty == true)
                            Text(
                              entry.value.phone!,
                              style: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}
