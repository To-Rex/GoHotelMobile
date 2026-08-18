import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/services/data_service.dart';
import 'admin_dashboard_controller.dart';

/// Xonalar boshqaruvi: qavatlar bo'yicha guruhlangan holatlar va
/// xona holatini o'zgartirish.
class AdminRoomsController extends GetxController {
  final _dataService = DataService();

  final rooms = <RoomModel>[].obs;
  final floors = <FloorModel>[].obs;
  final isLoading = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan)
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _dataService.getRooms(),
        _dataService.getFloors(),
      ]);
      rooms.value = (results[0] as List<RoomModel>)
          .where((r) => !r.isDeleted)
          .toList();
      floors.value = results[1] as List<FloorModel>;
      rooms.refresh();
      floors.refresh();
    } catch (_) {
      errorMessage.value = loadErrorText();
    } finally {
      isLoading.value = false;
    }
  }

  int statusCount(String status) =>
      rooms.where((r) => r.currentStatus == status).length;

  /// Qavat nomi bo'yicha guruhlangan xonalar (qavat raqami o'sish tartibida).
  List<MapEntry<String, List<RoomModel>>> get groupedByFloor {
    final floorById = {for (final f in floors) f.id: f};
    final groups = <String, List<RoomModel>>{};
    final orderKey = <String, int>{};

    for (final room in rooms) {
      final floor = floorById[room.floorId];
      final label = floor == null
          ? 'Boshqa'.tr
          : (floor.name?.isNotEmpty == true
                ? floor.name!
                : '${floor.floorNumber}-${'qavat'.tr}');
      groups.putIfAbsent(label, () => []).add(room);
      orderKey[label] = floor?.floorNumber ?? 1 << 20;
    }

    final entries = groups.entries.toList()
      ..sort((a, b) => orderKey[a.key]!.compareTo(orderKey[b.key]!));
    for (final entry in entries) {
      entry.value.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    }
    return entries;
  }

  /// Bir vaqtda bitta holat o'zgarishi — dublikat so'rovdan himoya
  final _statusBusy = false.obs;

  Future<void> changeStatus(RoomModel room, String status) async {
    if (_statusBusy.value) return;
    _statusBusy.value = true;
    try {
      final updated = await _dataService.updateRoomStatus(room.id, status);
      final index = rooms.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        rooms[index] = updated;
        rooms.refresh();
      } else {
        // Ro'yxat orada yangilangan bo'lsa — to'liq qayta yuklaymiz,
        // o'zgarish jimgina yo'qolib qolmasin
        await loadData();
      }
      if (Get.isRegistered<AdminDashboardController>()) {
        Get.find<AdminDashboardController>().loadData();
      }
      Get.snackbar(
        'Muvaffaqiyatli!'.tr,
        '${room.roomNumber} — ${RoomModel.statusLabel(status)}',
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
      _statusBusy.value = false;
    }
  }
}
