import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/photo_report_controller.dart';
import '../../../data/models/task_model.dart';

class PhotoReportPage extends GetView<PhotoReportController> {
  const PhotoReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final task = controller.task;
    final isPush = controller.isPushPage;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: isPush
          ? AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.onSurface),
                onPressed: () => Get.back(),
              ),
              title: Text(isPush ? 'Vazifani yakunlash' : 'Fotohisobot',
                  style: AppTextStyles.h2()),
            )
          : null,
      body: SafeArea(
        top: !isPush,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isPush)
                const AppHeader(
                  title: 'Fotohisobot',
                  showAvatar: true,
                  showBackButton: false,
                ),
              if (task != null) ...[
                _buildRoomInfo(task),
                const SizedBox(height: 24),
              ],
              _buildPhotoGrid(context),
              const SizedBox(height: 24),
              _buildUploadedSamples(),
              const SizedBox(height: 24),
              _buildCommentsField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              if (isPush) ...[
                const SizedBox(height: 12),
                _buildCancelButton(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomInfo(TaskModel task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('XONA RAQAMI', style: AppTextStyles.labelCaps()),
          const SizedBox(height: 4),
          Text(task.roomNumber, style: AppTextStyles.roomNumber()),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(task.roomType,
                style: AppTextStyles.labelCaps(color: AppColors.primary)),
          ),
          const SizedBox(height: 8),
          Text(
            '${task.floor} • ${task.guest ?? ''} • ${task.guestStatus ?? ''}',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    final sections = [
      {'icon': Icons.king_bed, 'title': 'YOTOQ QISMI'},
      {'icon': Icons.shower, 'title': 'VANNAXONA'},
      {'icon': Icons.photo_camera, 'title': 'UMUMIY KO\'RINISH'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RASMLAR', style: AppTextStyles.labelCaps()),
        const SizedBox(height: 8),
        Row(
          children: sections.map((section) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () =>
                      controller.pickImage(section['title'] as String),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                section['icon'] as IconData,
                                size: 32,
                                color: AppColors.outline,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                section['title'] as String,
                                style: AppTextStyles.labelCaps(
                                  color: AppColors.outline,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rasm yuklash uchun bosing',
                                style: AppTextStyles.bodyMd(
                                  color: AppColors.outline,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
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
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUploadedSamples() {
    return Obx(
      () {
        if (controller.pickedPhotos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined,
                    color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'YUKLANGAN RASMLAR NAMUNASI',
                  style:
                      AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                ),
                const Spacer(),
                Text(
                  '${controller.pickedPhotos.length}/3',
                  style:
                      AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'YUKLANGAN RASMLAR',
                  style: AppTextStyles.labelCaps(color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  '${controller.pickedPhotos.length}/3',
                  style: AppTextStyles.bodyMd(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.pickedPhotos.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(entry.value['path']!),
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
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QO\'SHIMCHA IZOH (IXTIYORIY)',
          style: AppTextStyles.labelCaps(),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (v) => controller.commentController.value = v,
          maxLines: 4,
          style: AppTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: 'Qo\'shimcha izoh yozish...',
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

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: controller.isUploading.value
              ? null
              : controller.submitReport,
          icon: controller.isUploading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Icon(controller.isPushPage ? Icons.task_alt : Icons.send),
          label: Text(
            controller.isUploading.value
                ? 'Yuborilmoqda...'
                : controller.isPushPage ? 'Yakunlash' : 'Hisobotni yuborish',
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
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('Bekor qilish',
            style: AppTextStyles.bodyLg(color: AppColors.primary)),
      ),
    );
  }
}
