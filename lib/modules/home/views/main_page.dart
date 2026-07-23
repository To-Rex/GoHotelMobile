import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../core/animations/app_animations.dart';
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
      extendBody: true,
      body: Obx(() {
        final index = controller.currentIndex.value;
        // IndexedStack holatni saqlaydi; tab almashganda yumshoq fade+ko'tarilish.
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
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
              HomePage(),
              TasksPage(),
              NotificationsPage(),
              ProfilePage(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTabChanged: controller.changeTab,
        ),
      ),
    );
  }
}
