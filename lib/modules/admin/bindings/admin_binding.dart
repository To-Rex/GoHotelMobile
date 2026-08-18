import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_finance_controller.dart';
import '../controllers/admin_guests_controller.dart';
import '../controllers/admin_main_controller.dart';
import '../controllers/admin_problems_controller.dart';
import '../controllers/admin_reservations_controller.dart';
import '../controllers/admin_rooms_controller.dart';
import '../controllers/admin_staff_controller.dart';
import '../controllers/admin_tasks_controller.dart';

/// Boshqaruv moduli: controller'lar fenix bilan ro'yxatga olinadi —
/// logout/login siklida qayta tiklanadi.
class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminMainController(), fenix: true);
    Get.lazyPut(() => AdminDashboardController(), fenix: true);
    Get.lazyPut(() => AdminTasksController(), fenix: true);
    Get.lazyPut(() => AdminRoomsController(), fenix: true);
    Get.lazyPut(() => AdminReservationsController(), fenix: true);
    Get.lazyPut(() => AdminProblemsController(), fenix: true);
    Get.lazyPut(() => AdminFinanceController(), fenix: true);
    Get.lazyPut(() => AdminStaffController(), fenix: true);
    Get.lazyPut(() => AdminGuestsController(), fenix: true);
  }
}
