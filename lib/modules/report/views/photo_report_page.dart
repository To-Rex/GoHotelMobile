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
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onSurface,
                ),
                onPressed: () => Get.back(),
              ),
              title: Text('Vazifani yakunlash'.tr, style: AppTextStyles.h2()),
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
                AppHeader(
                  title: 'Fotohisobot'.tr,
                  showAvatar: true,
                  showBackButton: false,
                ),
              if (task != null) ...[
                FadeSlideIn(index: 0, child: _buildRoomCard(task)),
                const SizedBox(height: 24),
              ],
              FadeSlideIn(index: 1, child: _buildPhotosSection()),
              const SizedBox(height: 24),
              FadeSlideIn(index: 2, child: _buildCommentsField()),
              const SizedBox(height: 28),
              FadeSlideIn(index: 3, child: _buildSubmitButton()),
              if (isPush) ...[
                const SizedBox(height: 12),
                FadeSlideIn(index: 4, child: _buildCancelButton()),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(TaskModel task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
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
                  task.roomNumber,
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
                  task.roomType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLg(),
                ),
                const SizedBox(height: 2),
                Text(
                  task.guest != null
                      ? '${task.floor} • ${task.guest}'
                      : task.floor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildPhotosSection() {
    return Obx(() {
      final photos = controller.pickedPhotos;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SURATLAR'.tr, style: AppTextStyles.labelCaps()),
              const Spacer(),
              if (photos.isNotEmpty)
                Text(
                  '${photos.length} ${'ta surat'.tr}',
                  style: AppTextStyles.labelCaps(color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            _buildCaptureCard()
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...photos.asMap().entries.map(
                  (entry) => _buildPhotoTile(entry.key, entry.value),
                ),
                _buildAddTile(),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildCaptureCard() {
    return Pressable(
      onTap: controller.pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1.6,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text('Suratga olish'.tr, style: AppTextStyles.bodyLg()),
            const SizedBox(height: 4),
            Text(
              'Xona holatini bir nechta suratga olishingiz mumkin'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(int index, String path) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: AppMotion.base,
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Pressable(
              onTap: () => controller.removePhoto(index),
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
    );
  }

  Widget _buildAddTile() {
    return Pressable(
      onTap: controller.pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_rounded,
              size: 26,
              color: AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              'Yana'.tr,
              style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QO\'SHIMCHA IZOH (IXTIYORIY)'.tr,
          style: AppTextStyles.labelCaps(),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (v) => controller.commentController.value = v,
          maxLines: 4,
          style: AppTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: 'Qo\'shimcha izoh yozish...'.tr,
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
    return Obx(() {
      final uploading = controller.isUploading.value;
      final ready = controller.pickedPhotos.isNotEmpty && !uploading;
      return Pressable(
        onTap: uploading ? null : controller.submitReport,
        child: AnimatedContainer(
          duration: AppMotion.base,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ready
                  ? const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ]
                  : [AppColors.outlineVariant, AppColors.outlineVariant],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: ready
                ? AppShadows.glow(AppColors.primary, alpha: 0.3)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (uploading)
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
                uploading
                    ? 'Yuborilmoqda...'.tr
                    : controller.isPushPage
                    ? 'Yakunlash'.tr
                    : 'Hisobotni yuborish'.tr,
                style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      );
    });
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
          child: Text(
            'Bekor qilish'.tr,
            style: AppTextStyles.bodyLg(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
