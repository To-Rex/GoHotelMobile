import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';
import '../../home/controllers/main_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';

class PhotoReportController extends GetxController {
  final _dataService = DataService();

  final pickedPhotos = <Map<String, String>>[].obs;
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

  List<Map<String, String>> get bedroomPhotos =>
      pickedPhotos.where((p) => p['section'] == 'YOTOQ QISMI').toList();
  List<Map<String, String>> get bathroomPhotos =>
      pickedPhotos.where((p) => p['section'] == 'VANNAXONA').toList();
  List<Map<String, String>> get generalPhotos =>
      pickedPhotos.where((p) => p['section'] == 'UMUMIY KO\'RINISH').toList();

  Future<void> pickImage(String section) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        pickedPhotos.add({'path': image.path, 'section': section});
      }
    } finally {
      _isPicking = false;
    }
  }

  void removePhoto(int index) {
    pickedPhotos.removeAt(index);
  }

  Future<void> submitReport() async {
    isUploading.value = true;

    if (isPushPage && task != null) {
      final success = await _dataService.submitPhotoReport(
        taskId: task!.id,
        photoPaths: pickedPhotos.map((p) => p['path']!).toList(),
        comment: commentController.value.isEmpty ? null : commentController.value,
      );
      if (success) {
        Get.find<TasksController>().updateTaskProgress(task!.id, 100);
      }
    }

    isUploading.value = false;
    pickedPhotos.clear();
    commentController.value = '';

    Get.snackbar(
      'Muvaffaqiyatli!',
      isPushPage ? 'Xona tozalandi va hisobot yuborildi' : 'Hisobot muvaffaqiyatli yuborildi',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCleanedBg,
      colorText: AppColors.statusCleaned,
    );

    if (isPushPage) {
      Get.close(2);
    } else {
      Get.find<MainController>().changeTab(0);
    }
  }
}
