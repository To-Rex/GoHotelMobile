import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';
import '../../home/controllers/main_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';

class PhotoReportController extends GetxController {
  final _dataService = DataService();

  final pickedPhotos = <String>[].obs;
  final isUploading = false.obs;
  final commentController = ''.obs;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  TaskModel? get task {
    final args = Get.arguments;
    if (args is TaskModel) return args;
    return null;
  }

  bool get isPushPage => task != null;

  Future<void> pickImage() async {
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
    if (isUploading.value) return;

    if (pickedPhotos.isEmpty) {
      Get.snackbar(
        'Surat kerak'.tr,
        'Kamida bitta surat oling'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.statusInProgressBg,
        colorText: AppColors.statusInProgress,
      );
      return;
    }

    isUploading.value = true;
    var success = true;
    if (isPushPage && task != null) {
      success = await _dataService.submitPhotoReport(
        taskId: task!.id,
        photoPaths: pickedPhotos.toList(),
        comment: commentController.value.isEmpty
            ? null
            : commentController.value,
      );
      if (success) {
        Get.find<TasksController>().updateTaskProgress(task!.id, 100);
      }
    }
    isUploading.value = false;

    if (!success) {
      // Suratlar o'chirilmaydi — farrosh qayta urinishi mumkin.
      Get.snackbar(
        'Xatolik'.tr,
        'Hisobot yuborilmadi. Internetni tekshirib, qayta urinib ko\'ring.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
      return;
    }

    pickedPhotos.clear();
    commentController.value = '';

    Get.snackbar(
      'Muvaffaqiyatli!'.tr,
      isPushPage
          ? 'Xona tozalandi va hisobot yuborildi'.tr
          : 'Hisobot muvaffaqiyatli yuborildi'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCleanedBg,
      colorText: AppColors.statusCleaned,
    );

    if (isPushPage) {
      // Qaysi yo'ldan kelinganidan qat'i nazar bosh ekranga qaytadi
      // (room-details orqali ham, to'g'ridan-to'g'ri ham).
      Get.until((route) => route.settings.name == '/home');
    } else {
      Get.find<MainController>().changeTab(0);
    }
  }
}
