import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gohotels/app/routes/app_routes.dart';
import 'package:gohotels/data/models/task_model.dart';
import 'package:gohotels/modules/home/controllers/home_controller.dart';
import 'package:gohotels/modules/tasks/controllers/tasks_controller.dart';

void main() {
  setUp(() => Get.reset());

  testWidgets(
      'Vazifalar keyin yuklansa ham home statistikasi avtomatik yangilanadi',
      (WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      getPages: AppRoutes.routes,
      home: const Scaffold(),
    ));

    final tasksController = Get.put(TasksController(), permanent: true);
    final homeController = Get.put(HomeController(), permanent: true);
    await tester.pump(const Duration(seconds: 1));

    // Boshlanishda server javobi hali kelmagan — hammasi bo'sh.
    expect(homeController.todayTasks, isEmpty);

    // Server javobi "keyinroq" keldi.
    tasksController.tasks.value = [
      TaskModel(
        id: 't1',
        roomNumber: '101',
        floor: '2-qavat',
        roomType: 'Standart',
        status: TaskStatus.pending,
      ),
      TaskModel(
        id: 't2',
        roomNumber: '102',
        floor: '2-qavat',
        roomType: 'Standart',
        status: TaskStatus.completed,
      ),
    ];
    await tester.pump();

    // Swipe-refresh'siz, avtomatik yangilanishi kerak.
    expect(homeController.todayTasks.length, 1);
    expect(homeController.pendingTasks.value, 1);
    expect(homeController.completedTasks.value, 1);
    await tester.pump(const Duration(seconds: 2));
  });
}
