import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
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
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text('Muammo haqida xabar berish', style: AppTextStyles.h2()),
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
                    _buildTaskInfo(controller.task!),
                    const SizedBox(height: 24),
                  ],
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildCategoryGrid(),
                  const SizedBox(height: 24),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  _buildPhotoUpload(),
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
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.roomNumber, style: AppTextStyles.h2()),
                Text('${task.floor} • ${task.roomType}',
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
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
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Muammo haqida xabar berish', style: AppTextStyles.h2()),
          const SizedBox(height: 8),
          Text(
            'Xonada siniq buyum, chiroy kuygan joy, texnik nosozlik yoki boshqa muammo bo\'lsa, quyidagi shakl orqali xabar bering va foto hisobot qo\'shing.',
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
        Text('KATEGORIYA', style: AppTextStyles.labelCaps()),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.problemCategories.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceContainerHigh
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
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
                        category,
                        style: AppTextStyles.bodyMd(
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
        return Icons.broken_image;
      case 'Texnik nosozlik':
        return Icons.engineering;
      case 'Suv sizishi':
        return Icons.water_drop;
      case 'Chiroy kuygan':
        return Icons.format_paint;
      case 'Elektr nosozligi':
        return Icons.electrical_services;
      case 'Mexanizm buzilgan':
        return Icons.build_circle;
      case 'Boshqa':
        return Icons.more_horiz;
      default:
        return Icons.report_problem;
    }
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAFSILOTLAR', style: AppTextStyles.labelCaps()),
        const SizedBox(height: 8),
        TextField(
          onChanged: (v) => controller.descriptionController.value = v,
          maxLines: 4,
          style: AppTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: 'Muammoning tafsilotlarini kiriting...',
            hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
          Text('FOTO HISOBOT', style: AppTextStyles.labelCaps()),
          const SizedBox(height: 4),
          Text(
            'Muammo joyidan suratga oling (Max 3 ta)',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (controller.pickedPhotos.isEmpty)
            GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  color: AppColors.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rasm qo\'shish uchun bosing',
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
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                          child: GestureDetector(
                            onTap: () => controller.removePhoto(entry.key),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: AppColors.onError),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (controller.pickedPhotos.length < 3)
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 2,
                        ),
                        color: AppColors.surfaceContainerLowest,
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 32,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.pickedPhotos.length}/3 rasm yuklandi',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                controller.isSubmitting.value ? null : controller.submitReport,
            icon: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              controller.isSubmitting.value
                  ? 'Yuborilmoqda...'
                  : 'Xabar yuborish',
              style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    ),
  );
  }
}
