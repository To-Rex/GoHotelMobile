import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/problem_model.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_problems_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

class AdminProblemsPage extends GetView<AdminProblemsController> {
  const AdminProblemsPage({super.key});

  static const _filters = [
    ('', 'Hammasi'),
    ('OPEN', 'Ochiq'),
    ('IN_PROGRESS', 'Jarayonda'),
    ('RESOLVED', 'Hal qilingan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Muammolar'.tr,
              subtitle: 'Farroshlar yuborgan xabarlar'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(index: 1, child: _buildFilterChips()),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadProblems,
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

  Widget _buildContent() {
    if (controller.isLoading.value && controller.problems.isEmpty) {
      return const AdminSkeletonList(count: 5, height: 110);
    }

    if (controller.problems.isEmpty) {
      // Tarmoq xatosi bo'sh ro'yxatdan ajratiladi — retry tugmasi bilan
      final error = controller.errorMessage.value;
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: error == null ? Icons.task_alt_rounded : Icons.wifi_off_rounded,
          message: error ?? 'Muammolar yo\'q'.tr,
          actionLabel: error == null ? null : 'Qayta urinish'.tr,
          onAction: error == null ? null : controller.loadProblems,
        ),
      );
    }

    return Column(
      children: controller.problems
          .asMap()
          .entries
          .map(
            (entry) => FadeSlideIn(
              index: entry.key.clamp(0, 12),
              child: _buildProblemCard(entry.value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProblemCard(ProblemModel problem) {
    final color = problemStatusColor(problem.status);
    return Pressable(
      onTap: () => _showDetail(problem),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    problem.category.tr,
                    style: AppTextStyles.bodyLg(),
                  ),
                ),
                AdminChip(
                  label: ProblemModel.statusLabel(problem.status),
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              problem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                if (problem.roomNumber != null)
                  Text(
                    '${'Xona'.tr} ${problem.roomNumber}',
                    style: AppTextStyles.labelCaps(color: AppColors.primary),
                  ),
                if (problem.reportedByName.isNotEmpty)
                  Text(
                    problem.reportedByName,
                    style: AppTextStyles.labelCaps(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetail(ProblemModel problem) async {
    // So'rov ketayotganda takror bosish e'tiborsiz — sheet ustma-ust ochilmasin
    if (controller.isDetailLoading.value) return;

    final main = Get.find<AdminMainController>();
    final canUpdate = main.can('housekeeping.task.update');

    // Suratlar faqat tafsilot endpointida keladi.
    ProblemModel detail = problem;
    final loaded = await controller.loadDetail(problem.id);
    if (loaded != null) detail = loaded;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
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
              Row(
                children: [
                  Expanded(
                    child: Text(detail.category.tr, style: AppTextStyles.h2()),
                  ),
                  AdminChip(
                    label: ProblemModel.statusLabel(detail.status),
                    color: problemStatusColor(detail.status),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(detail.description, style: AppTextStyles.bodyMd()),
              const SizedBox(height: 10),
              Text(
                [
                  if (detail.roomNumber != null)
                    '${'Xona'.tr} ${detail.roomNumber}',
                  if (detail.reportedByName.isNotEmpty) detail.reportedByName,
                ].join(' • '),
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              if (detail.photos.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        detail.photos[index].downloadUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 110,
                          height: 110,
                          color: AppColors.surfaceContainer,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (canUpdate && !detail.isResolved) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (detail.isOpen) ...[
                      Expanded(
                        child: _sheetButton(
                          'Jarayonga olish'.tr,
                          AppColors.surfaceContainer,
                          AppColors.primary,
                          () {
                            Get.back();
                            controller.changeStatus(detail, 'IN_PROGRESS');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: _sheetButton(
                        'Hal qilindi'.tr,
                        AppColors.primaryContainer,
                        AppColors.onPrimary,
                        () {
                          Get.back();
                          controller.changeStatus(detail, 'RESOLVED');
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        // Tor ekranda yozuv tugmadan toshmasdan o'zi kichrayadi
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: AppTextStyles.statusBadge(color: fg)),
        ),
      ),
    );
  }
}
