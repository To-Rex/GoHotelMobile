import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
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
                icon: const Icon(Icons.arrow_back_rounded,
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
                FadeSlideIn(index: 0, child: _buildRoomInfo(task)),
                const SizedBox(height: 24),
              ],
              FadeSlideIn(index: 1, child: _buildPhotoGrid(context)),
              const SizedBox(height: 24),
              FadeSlideIn(index: 2, child: _buildUploadedSamples()),
              const SizedBox(height: 24),
              FadeSlideIn(index: 3, child: _buildCommentsField()),
              const SizedBox(height: 32),
              FadeSlideIn(index: 4, child: _buildSubmitButton()),
              if (isPush) ...[
                const SizedBox(height: 12),
                FadeSlideIn(index: 5, child: _buildCancelButton()),
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('XONA RAQAMI', style: AppTextStyles.labelCaps()),
          const SizedBox(height: 4),
          Text(task.roomNumber, style: AppTextStyles.roomNumber()),
          const SizedBox(height: 6),
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
      (icon: Icons.king_bed_rounded, title: 'YOTOQ QISMI'),
      (icon: Icons.shower_rounded, title: 'VANNAXONA'),
      (icon: Icons.photo_camera_rounded, title: 'UMUMIY KO\'RINISH'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RASMLAR', style: AppTextStyles.labelCaps()),
        const SizedBox(height: 10),
        Row(
          children: sections.map((section) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Pressable(
                  onTap: () => controller.pickImage(section.title),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          width: 1.6,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.07),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  section.icon,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                section.title,
                                style: AppTextStyles.labelCaps(
                                  color: AppColors.onSurfaceVariant,
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
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined,
                    color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'YUKLANGAN RASMLAR NAMUNASI',
                    style: AppTextStyles.labelCaps(
                        color: AppColors.onSurfaceVariant),
                  ),
                ),
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.pickedPhotos.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
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
                          File(entry.value['path']!),
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
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: AppColors.onError),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        const SizedBox(height: 10),
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

  Widget _buildSubmitButton() {
    return Obx(
      () => Pressable(
        onTap: controller.isUploading.value ? null : controller.submitReport,
        child: AnimatedContainer(
          duration: AppMotion.base,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: controller.isUploading.value
                  ? [AppColors.outlineVariant, AppColors.outlineVariant]
                  : const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: controller.isUploading.value
                ? null
                : AppShadows.glow(AppColors.primary, alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isUploading.value)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                Icon(
                  controller.isPushPage
                      ? Icons.task_alt_rounded
                      : Icons.send_rounded,
                  color: AppColors.onPrimary,
                ),
              const SizedBox(width: 8),
              Text(
                controller.isUploading.value
                    ? 'Yuborilmoqda...'
                    : controller.isPushPage
                        ? 'Yakunlash'
                        : 'Hisobotni yuborish',
                style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Pressable(
      onTap: () => Get.back(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Text('Bekor qilish',
              style: AppTextStyles.bodyLg(color: AppColors.primary)),
        ),
      ),
    );
  }
}
