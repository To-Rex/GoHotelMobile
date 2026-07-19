import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TasksController(), permanent: true);
  }
}
