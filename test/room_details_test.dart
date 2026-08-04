import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gohotels/app/routes/app_routes.dart';
import 'package:gohotels/data/models/task_model.dart';

Widget _testApp(TaskModel task) {
  return GetMaterialApp(
    getPages: AppRoutes.routes,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => Get.toNamed('/room-details', arguments: task),
          child: const Text('go'),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => Get.reset());

  testWidgets('Yakunlash tugmasi: /room-details argument bilan ochiladi',
      (WidgetTester tester) async {
    final task = TaskModel(
      id: 't1',
      roomNumber: '101',
      floor: '2-qavat',
      roomType: 'Standart',
      guest: 'Ali Valiyev',
      guestStatus: 'Band',
      status: TaskStatus.inProgress,
      progress: 40,
      checklist: [ChecklistItem(id: 'c1', title: 'Pol yuvish')],
    );

    await tester.pumpWidget(_testApp(task));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Xona 101'), findsOneWidget);
    expect(find.text('Tekshirish ro\'yxati'), findsOneWidget);
    expect(find.text('QO\'SHIMCHA MA\'LUMOT'), findsOneWidget);
    expect(find.text('Pol yuvish'), findsOneWidget);
  });

  testWidgets('Bo\'sh checklist: tushuntiruvchi xabar ko\'rinadi',
      (WidgetTester tester) async {
    final task = TaskModel(
      id: 't2',
      roomNumber: '202',
      floor: '3-qavat',
      roomType: 'Lyuks',
      status: TaskStatus.pending,
    );

    await tester.pumpWidget(_testApp(task));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Xona 202'), findsOneWidget);
    expect(find.text('Ro\'yxat biriktirilmagan'), findsOneWidget);
    expect(find.text('QO\'SHIMCHA MA\'LUMOT'), findsOneWidget);
    expect(find.text('Ma\'lumot yo\'q'), findsOneWidget);
    expect(find.text('Belgilanmagan'), findsOneWidget);
  });
}
