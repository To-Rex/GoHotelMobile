import 'package:get/get.dart';
import '../controllers/photo_report_controller.dart';
import '../controllers/problem_report_controller.dart';
import '../../../data/models/task_model.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhotoReportController());
    Get.lazyPut(() => ProblemReportController());
  }
}

class ProblemReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProblemReportController>(() {
      final task = Get.arguments as TaskModel?;
      return ProblemReportController(task: task);
    }, fenix: true);
  }
}
