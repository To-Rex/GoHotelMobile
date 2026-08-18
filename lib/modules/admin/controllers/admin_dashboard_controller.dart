import 'package:get/get.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/hk_task_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/services/data_service.dart';

/// Boshqaruv dashboard'i: backend'da agregat endpoint yo'q (web ham shunday),
/// shuning uchun statistika ro'yxatlardan mijoz tomonida hisoblanadi.
class AdminDashboardController extends GetxController {
  final _dataService = DataService();

  final rooms = <RoomModel>[].obs;
  final tasks = <HkTaskModel>[].obs;
  final isLoading = false.obs;

  /// Tarmoq xatosi — nol ko'rsatkichlardan farqlash uchun
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
        _dataService.getRooms(),
        _dataService.getHkTasks(),
      ]);
      rooms.value = (results[0] as List<RoomModel>)
          .where((r) => !r.isDeleted)
          .toList();
      tasks.value = results[1] as List<HkTaskModel>;
      rooms.refresh();
      tasks.refresh();
      errorMessage.value = null;
    } catch (_) {
      errorMessage.value = loadErrorText();
    } finally {
      isLoading.value = false;
    }
  }

  int get totalRooms => rooms.length;

  int statusCount(String status) =>
      rooms.where((r) => r.currentStatus == status).length;

  /// Band + bron qilingan xonalar ulushi (web dashboard bilan bir xil formula).
  double get occupancy {
    if (rooms.isEmpty) return 0;
    final busy = statusCount('OCCUPIED') + statusCount('RESERVED');
    return busy / rooms.length;
  }

  int get openTaskCount => tasks.where((t) => t.isOpen).length;
  int get inProgressTaskCount => tasks.where((t) => t.isInProgress).length;
  int get completedTaskCount => tasks.where((t) => t.isCompleted).length;

  /// Dashborddagi "so'nggi faol vazifalar" ro'yxati.
  List<HkTaskModel> get recentActiveTasks =>
      tasks.where((t) => t.isActive).take(5).toList();
}
