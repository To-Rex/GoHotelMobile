import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/problem_model.dart';
import '../../../data/services/data_service.dart';

/// Farroshlar yuborgan muammolar: ro'yxat, suratli tafsilot, holat o'zgartirish.
class AdminProblemsController extends GetxController {
  final _dataService = DataService();

  final problems = <ProblemModel>[].obs;
  final selectedStatus = ''.obs; // '' — hammasi
  final isLoading = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan)
  final errorMessage = RxnString();

  /// Tafsilot so'rovi ketmoqda — takror bosishda sheet ustma-ust ochilmasin
  final isDetailLoading = false.obs;

  /// Holat o'zgartirish ketmoqda — dublikat PATCH oldini oladi
  final isStatusBusy = false.obs;

  /// Filtr tez almashtirilganda eski javob yangisini bosib qo'ymasin
  int _requestSeq = 0;

  @override
  void onInit() {
    super.onInit();
    loadProblems();
  }

  Future<void> loadProblems() async {
    final seq = ++_requestSeq;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await _dataService.getProblems(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      if (seq != _requestSeq) return; // eskirgan javob
      problems.value = list;
      problems.refresh();
    } catch (_) {
      if (seq != _requestSeq) return;
      errorMessage.value = loadErrorText();
    } finally {
      if (seq == _requestSeq) isLoading.value = false;
    }
  }

  void changeFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    problems.clear();
    loadProblems();
  }

  /// Tafsilot — bir vaqtda bittadan (sekin tarmoqda qotib qolgandek
  /// ko'rinib, qayta bosishda bir nechta sheet ochilib ketardi)
  Future<ProblemModel?> loadDetail(String id) async {
    if (isDetailLoading.value) return null;
    isDetailLoading.value = true;
    try {
      return await _dataService.getProblemDetail(id);
    } catch (_) {
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> changeStatus(ProblemModel problem, String status) async {
    if (isStatusBusy.value) return;
    isStatusBusy.value = true;
    try {
      await _dataService.updateProblemStatus(problem.id, status);
      final filter = selectedStatus.value;
      if (filter.isNotEmpty && filter != status) {
        // Yangi holat joriy filtrga mos kelmaydi — ro'yxat qayta yuklanadi,
        // aks holda "Ochiq" filtri ostida hal qilingan muammo qolib ketardi
        await loadProblems();
      } else {
        final index = problems.indexWhere((p) => p.id == problem.id);
        if (index != -1) {
          problems[index] = problems[index].copyWith(status: status);
          problems.refresh();
        } else {
          await loadProblems();
        }
      }
      Get.snackbar(
        'Muvaffaqiyatli!'.tr,
        'Muammo holati yangilandi'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.statusCleanedBg,
        colorText: AppColors.statusCleaned,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik'.tr,
        apiErrorText(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
    } finally {
      isStatusBusy.value = false;
    }
  }
}
