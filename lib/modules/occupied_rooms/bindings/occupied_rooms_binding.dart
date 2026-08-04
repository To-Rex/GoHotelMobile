import 'package:get/get.dart';
import '../controllers/occupied_rooms_controller.dart';

class OccupiedRoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OccupiedRoomsController(), fenix: true);
  }
}
