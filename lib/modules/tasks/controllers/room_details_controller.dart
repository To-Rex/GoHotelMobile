import 'package:get/get.dart';
import '../../../data/models/occupied_room_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/data_service.dart';

/// Xona sahifasi uchun qo'shimcha ma'lumot: xona hozir band bo'lsa,
/// mehmonning kutilayotgan chiqish vaqtini occupied-rooms API'dan oladi.
class RoomDetailsController extends GetxController {
  final _dataService = DataService();

  final occupiedInfo = Rxn<OccupiedRoomModel>();
  final isLoadingOccupied = false.obs;

  @override
  void onInit() {
    super.onInit();
    final task = Get.arguments;
    if (task is TaskModel) loadOccupiedInfo(task.roomNumber);
  }

  Future<void> loadOccupiedInfo(String roomNumber) async {
    isLoadingOccupied.value = true;
    try {
      final rooms = await _dataService.getOccupiedRooms();
      OccupiedRoomModel? match;
      for (final room in rooms) {
        if (room.roomNumber == roomNumber) {
          match = room;
          break;
        }
      }
      occupiedInfo.value = match;
    } catch (_) {
    } finally {
      isLoadingOccupied.value = false;
    }
  }
}
