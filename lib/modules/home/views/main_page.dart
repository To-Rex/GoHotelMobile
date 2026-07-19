import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../home/views/home_page.dart';
import '../../tasks/views/tasks_page.dart';
import '../../notifications/views/notifications_page.dart';
import '../../profile/views/profile_page.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomePage(),
            TasksPage(),
            NotificationsPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTabChanged: controller.changeTab,
        ),
      ),
    );
  }
}
