import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';

void main() async {
  await GetStorage.init();
  runApp(const GoHotelApp());
}

class GoHotelApp extends StatelessWidget {
  const GoHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoHotel Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 380),
      initialRoute: AppRoutes.initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
