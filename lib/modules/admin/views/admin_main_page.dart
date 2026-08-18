import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/animations/app_animations.dart';
import '../../profile/views/profile_page.dart';
import '../controllers/admin_main_controller.dart';
import 'admin_dashboard_page.dart';
import 'admin_finance_page.dart';
import 'admin_guests_page.dart';
import 'admin_problems_page.dart';
import 'admin_reservations_page.dart';
import 'admin_rooms_page.dart';
import 'admin_staff_page.dart';
import 'admin_tasks_page.dart';
import 'widgets/admin_drawer.dart';

/// Boshqaruv (admin/menejer) shell'i — navigatsiya drawer orqali.
/// Farroshdagi bottom nav bunga aloqasiz, o'z holicha qoladi.
class AdminMainPage extends GetView<AdminMainController> {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.surface,
      drawer: const AdminDrawer(),
      body: Obx(() {
        final index = controller.currentIndex.value;
        // DIQQAT: bu yerga ValueKey(index) QO'YILMAYDI — u butun IndexedStack
        // va 9 sahifani har tab almashishida qayta yaratib, scroll/holatni
        // yo'qotar va barcha so'rovlarni qayta otar edi. IndexedStack holati
        // saqlansin, faqat indeks almashsin.
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.base,
          curve: AppMotion.enter,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - t)),
              child: child,
            ),
          ),
          child: IndexedStack(
            index: index,
            children: const [
              AdminDashboardPage(),
              AdminReservationsPage(),
              AdminTasksPage(),
              AdminRoomsPage(),
              AdminStaffPage(),
              AdminGuestsPage(),
              AdminProblemsPage(),
              AdminFinancePage(),
              ProfilePage(),
            ],
          ),
        );
      }),
    );
  }
}
