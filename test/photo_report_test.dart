import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gohotels/app/routes/app_routes.dart';
import 'package:gohotels/data/models/task_model.dart';

void main() {
  setUp(() => Get.reset());

  testWidgets('Vazifani yakunlash sahifasi: bo\'limlarsiz, sodda ko\'rinish',
      (WidgetTester tester) async {
    final task = TaskModel(
      id: 't1',
      roomNumber: '101',
      floor: '2-qavat',
      roomType: 'Standart',
      guest: 'A. Valiyev',
      status: TaskStatus.inProgress,
    );

    await tester.pumpWidget(GetMaterialApp(
      getPages: AppRoutes.routes,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Get.toNamed('/photo-report', arguments: task),
            child: const Text('go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Vazifani yakunlash'), findsOneWidget);
    expect(find.text('Suratga olish'), findsOneWidget);
    expect(find.text('Yakunlash'), findsOneWidget);
    expect(find.text('Bekor qilish'), findsOneWidget);

    // Eski bo'limlar olib tashlangan.
    expect(find.text('YOTOQ QISMI'), findsNothing);
    expect(find.text('VANNAXONA'), findsNothing);
    expect(find.text('UMUMIY KO\'RINISH'), findsNothing);
  });
}
