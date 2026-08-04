import 'dart:async';

import 'package:get/get.dart';
import '../../../data/models/occupied_room_model.dart';
import '../../../data/services/data_service.dart';

class OccupiedRoomsController extends GetxController {
  final _dataService = DataService();

  final rooms = <OccupiedRoomModel>[].obs;
  final isLoading = false.obs;

  /// Standart true: band (CHECKED_IN) bilan birga bron qilingan (CONFIRMED)
  /// xonalar ham ko'rsatiladi. Sahifadagi toggle bilan o'chirish mumkin.
  final includeReserved = true.obs;

  /// Qolgan vaqt hisobi qurilma soat mintaqasiga bog'liq bo'lmasligi uchun
  /// server bergan daqiqadan yuklangandan beri o'tgan vaqt ayiriladi.
  DateTime? _fetchedAt;

  /// Har daqiqada Obx'larni qayta qurish uchun ichki hisoblagich.
  final _tick = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick.value++);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadRooms() async {
    isLoading.value = true;
    try {
      rooms.value = await _dataService.getOccupiedRooms(
        includeReserved: includeReserved.value,
      );
      _fetchedAt = DateTime.now();
      rooms.refresh();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void toggleReserved() {
    includeReserved.value = !includeReserved.value;
    loadRooms();
  }

  /// Jonli qoldiq daqiqa; kechikkan bo'lsa manfiy.
  int minutesLeft(OccupiedRoomModel room) {
    _tick.value;
    final elapsed = _fetchedAt == null
        ? 0
        : DateTime.now().difference(_fetchedAt!).inMinutes;
    return room.minutesUntilCheckout - elapsed;
  }

  int get totalCount => rooms.length;

  int get overdueCount => rooms.where((r) => minutesLeft(r) < 0).length;

  /// 1 soat ichida bo'shaydigan xonalar.
  int get soonCount => rooms.where((r) {
    final m = minutesLeft(r);
    return m >= 0 && m <= 60;
  }).length;
}
