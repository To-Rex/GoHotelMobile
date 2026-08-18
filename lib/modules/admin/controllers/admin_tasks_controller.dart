import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/hk_task_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/services/data_service.dart';
import 'admin_dashboard_controller.dart';

/// Vazifalar boshqaruvi: ro'yxat, yaratish, biriktirish, holat o'zgartirish.
class AdminTasksController extends GetxController {
  final _dataService = DataService();

  final tasks = <HkTaskModel>[].obs;
  final selectedStatus = ''.obs; // '' — hammasi
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan)
  final errorMessage = RxnString();

  /// Amal bajarilayotgan vazifalar — tugmalar bloklanadi (dublikat yo'q)
  final busyTaskIds = <String>{}.obs;

  /// Filtr tez almashtirilganda eski javob yangisini bosib qo'ymasin
  int _requestSeq = 0;

  // Yaratish formasi uchun ma'lumotnomalar.
  final employees = <StaffModel>[].obs;
  final branches = <BranchModel>[].obs;
  final rooms = <RoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    loadReferenceData();
  }

  Future<void> loadTasks() async {
    final seq = ++_requestSeq;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await _dataService.getHkTasks(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      if (seq != _requestSeq) return; // eskirgan javob
      tasks.value = list;
      tasks.refresh();
    } catch (_) {
      if (seq != _requestSeq) return;
      errorMessage.value = loadErrorText();
    } finally {
      if (seq == _requestSeq) isLoading.value = false;
    }
  }

  Future<void> loadReferenceData() async {
    try {
      final results = await Future.wait([
        _dataService.getEmployees(),
        _dataService.getBranches(),
        _dataService.getRooms(),
      ]);
      // Faol bo'lmagan xodimga vazifa biriktirib bo'lmaydi
      employees.value = (results[0] as List<StaffModel>)
          .where((s) => s.isActive)
          .toList();
      branches.value = results[1] as List<BranchModel>;
      rooms.value = (results[2] as List<RoomModel>)
          .where((r) => !r.isDeleted)
          .toList();
    } catch (_) {}
  }

  void changeFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    tasks.clear();
    loadTasks();
  }

  bool isTaskBusy(String id) => busyTaskIds.contains(id);

  Future<bool> createTask({
    required String branchId,
    required String roomId,
    required String taskType,
    required String priority,
    String? assignedTo,
    String? notes,
    String? scheduledDate,
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      await _dataService.createHkTask(
        branchId: branchId,
        roomId: roomId,
        taskType: taskType,
        priority: priority,
        assignedTo: assignedTo,
        notes: notes,
        scheduledDate: scheduledDate,
      );
      await loadTasks();
      _refreshDashboard();
      Get.snackbar(
        'Muvaffaqiyatli!'.tr,
        'Vazifa yaratildi'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.statusCleanedBg,
        colorText: AppColors.statusCleaned,
      );
      return true;
    } catch (e) {
      _showError(e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> changeStatus(HkTaskModel task, String status) async {
    if (busyTaskIds.contains(task.id)) return;
    busyTaskIds.add(task.id);
    try {
      final updated = await _dataService.updateHkTaskStatus(task.id, status);
      _replace(updated);
      _refreshDashboard();
    } catch (e) {
      _showError(e);
    } finally {
      busyTaskIds.remove(task.id);
    }
  }

  Future<void> assign(HkTaskModel task, String staffId) async {
    if (busyTaskIds.contains(task.id)) return;
    busyTaskIds.add(task.id);
    try {
      final updated = await _dataService.assignHkTask(task.id, staffId);
      _replace(updated);
    } catch (e) {
      _showError(e);
    } finally {
      busyTaskIds.remove(task.id);
    }
  }

  void _replace(HkTaskModel updated) {
    final index = tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      // Filtr endi mos kelmasa ham ro'yxatda yangilangan holat ko'rinadi;
      // keyingi yangilashda filtr qayta qo'llanadi.
      tasks[index] = updated;
      tasks.refresh();
    } else {
      loadTasks();
    }
  }

  void _refreshDashboard() {
    if (Get.isRegistered<AdminDashboardController>()) {
      Get.find<AdminDashboardController>().loadData();
    }
  }

  void _showError(Object e) {
    Get.snackbar(
      'Xatolik'.tr,
      apiErrorText(e),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorContainer,
      colorText: AppColors.onErrorContainer,
    );
  }
}
