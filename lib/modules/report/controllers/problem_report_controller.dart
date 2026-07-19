import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';

class ProblemReportController extends GetxController {
  final _dataService = DataService();

  final TaskModel? task;
  final selectedCategory = AppConstants.problemCategories[0].obs;
  final descriptionController = ''.obs;
  final pickedPhotos = <String>[].obs;
  final isSubmitting = false.obs;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  ProblemReportController({this.task});

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> pickImage() async {
    if (pickedPhotos.length >= 3) return;
    if (_isPicking) return;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        pickedPhotos.add(image.path);
      }
    } finally {
      _isPicking = false;
    }
  }

  void removePhoto(int index) {
    pickedPhotos.removeAt(index);
  }

  Future<void> submitReport() async {
    if (descriptionController.value.isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, muammoning tafsilotlarini kiriting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    if (pickedPhotos.isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, muammo joyidan suratga oling',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    isSubmitting.value = true;

    final success = await _dataService.submitProblemReport(
      taskId: task?.id,
      category: selectedCategory.value,
      description: descriptionController.value,
      photoPaths: pickedPhotos.toList(),
      roomNumber: task?.roomNumber,
    );

    if (!success) {
      isSubmitting.value = false;
      Get.snackbar(
        'Xatolik',
        'Hisobot yuborishda xatolik yuz berdi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    descriptionController.value = '';
    pickedPhotos.clear();
    selectedCategory.value = AppConstants.problemCategories[0];
    isSubmitting.value = false;

    Get.snackbar(
      'Muvaffaqiyatli!',
      'Muammo haqida xabar yuborildi',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCleanedBg,
      colorText: AppColors.statusCleaned,
    );

    Get.back();
  }
}
