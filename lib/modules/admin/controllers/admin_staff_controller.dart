import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/services/data_service.dart';
import 'admin_tasks_controller.dart';

/// Xodimlar boshqaruvi: ro'yxat, yaratish, tahrirlash, holat o'zgartirish.
class AdminStaffController extends GetxController {
  final _dataService = DataService();

  final staff = <StaffModel>[].obs;
  final branches = <BranchModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan)
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _dataService.getAllStaff(),
        _dataService.getBranches(),
      ]);
      staff.value = results[0] as List<StaffModel>;
      branches.value = results[1] as List<BranchModel>;
      staff.refresh();
      errorMessage.value = null;
    } catch (_) {
      errorMessage.value = loadErrorText();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createStaff({
    required String branchId,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    String? phone,
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      await _dataService.createEmployee(
        branchId: branchId,
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
        phone: phone,
      );
      await loadData();
      _refreshAssignees();
      _success('Xodim qo\'shildi'.tr);
      return true;
    } catch (e) {
      _showError(e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateStaff(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? status,
  }) async {
    if (isSubmitting.value) return false;
    isSubmitting.value = true;
    try {
      await _dataService.updateEmployee(
        id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        status: status,
      );
      await loadData();
      _refreshAssignees();
      _success('Xodim ma\'lumotlari yangilandi'.tr);
      return true;
    } catch (e) {
      _showError(e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Vazifa biriktirish ro'yxati ham yangilanib turishi uchun.
  void _refreshAssignees() {
    if (Get.isRegistered<AdminTasksController>()) {
      Get.find<AdminTasksController>().loadReferenceData();
    }
  }

  void _success(String message) {
    Get.snackbar(
      'Muvaffaqiyatli!'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCleanedBg,
      colorText: AppColors.statusCleaned,
    );
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
