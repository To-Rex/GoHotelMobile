import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../controllers/problem_report_controller.dart';

class ProblemReportPage extends GetView<ProblemReportController> {
  const ProblemReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasTask = controller.task != null;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Muammo haqida xabar berish'.tr, style: AppTextStyles.h2()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasTask) ...[
                    FadeSlideIn(
                      index: 0,
                      child: _buildTaskInfo(controller.task!),
                    ),
                    const SizedBox(height: 24),
                  ],
                  FadeSlideIn(index: 1, child: _buildHeaderCard()),
                  const SizedBox(height: 24),
                  FadeSlideIn(index: 2, child: _buildCategoryGrid()),
                  const SizedBox(height: 24),
                  FadeSlideIn(index: 3, child: _buildDescriptionField()),
                  const SizedBox(height: 24),
                  FadeSlideIn(index: 4, child: _buildPhotoUpload()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildSubmitBar(),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(TaskModel task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.roomNumber, style: AppTextStyles.h2()),
                Text(
                  '${task.floor} • ${task.roomType}',
                  style: AppTextStyles.bodyMd(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.report_problem_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text('Muammo haqida xabar berish'.tr, style: AppTextStyles.h2()),
          const SizedBox(height: 8),
          Text(
            'Xonada siniq buyum, chiroy kuygan joy, texnik nosozlik yoki boshqa muammo bo\'lsa, quyidagi shakl orqali xabar bering va foto hisobot qo\'shing.'
                .tr,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KATEGORIYA'.tr, style: AppTextStyles.labelCaps()),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.problemCategories.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return Pressable(
                onTap: () => controller.selectCategory(category),
                pressedScale: 0.95,
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.emphasized,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.6),
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: isSelected
                        ? AppShadows.glow(AppColors.primary, alpha: 0.15)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.tr,
                        style: AppTextStyles.statusBadge(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Siniq buyum':
        return Icons.broken_image_rounded;
      case 'Texnik nosozlik':
        return Icons.engineering_rounded;
      case 'Suv sizishi':
        return Icons.water_drop_rounded;
      case 'Chiroy kuygan':
        return Icons.format_paint_rounded;
      case 'Elektr nosozligi':
        return Icons.electrical_services_rounded;
      case 'Mexanizm buzilgan':
        return Icons.build_circle_rounded;
      case 'Boshqa':
        return Icons.more_horiz_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAFSILOTLAR'.tr, style: AppTextStyles.labelCaps()),
        const SizedBox(height: 10),
        TextField(
          onChanged: (v) => controller.descriptionController.value = v,
          maxLines: 4,
          style: AppTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: 'Muammoning tafsilotlarini kiriting...'.tr,
            hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
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
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOTO HISOBOT'.tr, style: AppTextStyles.labelCaps()),
          const SizedBox(height: 4),
          Text(
            'Muammo joyidan suratga oling (Max 3 ta)'.tr,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (controller.pickedPhotos.isEmpty)
            Pressable(
              onTap: controller.pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                    width: 1.6,
                  ),
                  color: AppColors.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rasm qo\'shish uchun bosing'.tr,
                      style: AppTextStyles.bodyMd(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ),
          if (controller.pickedPhotos.isNotEmpty) ...[
            Row(
              children: [
                ...controller.pickedPhotos.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1),
                      duration: AppMotion.base,
                      curve: Curves.easeOutBack,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(entry.value),
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Pressable(
                              onTap: () => controller.removePhoto(entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.onError,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (controller.pickedPhotos.length < 3)
                  Pressable(
                    onTap: controller.pickImage,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                          width: 1.6,
                        ),
                        color: AppColors.surfaceContainerLowest,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.pickedPhotos.length}/3 ${'rasm yuklandi'.tr}',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Builder(
      builder: (context) => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Obx(
              () => Pressable(
                onTap: controller.isSubmitting.value
                    ? null
                    : controller.submitReport,
                child: AnimatedContainer(
                  duration: AppMotion.base,
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.isSubmitting.value
                          ? [AppColors.outlineVariant, AppColors.outlineVariant]
                          : const [
                              AppColors.primaryContainer,
                              AppColors.secondaryContainer,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: controller.isSubmitting.value
                        ? null
                        : AppShadows.glow(AppColors.primary, alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.isSubmitting.value)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.send_rounded,
                          color: AppColors.onPrimary,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isSubmitting.value
                            ? 'Yuborilmoqda...'.tr
                            : 'Xabar yuborish'.tr,
                        style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
