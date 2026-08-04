import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gohotels/firebase_options.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/translations/app_translations.dart';
import 'core/storage/local_storage.dart';
import 'data/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Fon/yopiq holatdagi push'lar uchun — runApp'dan oldin ro'yxatdan o'tishi shart.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Servis permanent: ilova hayoti davomida bitta nusxa yashaydi.
  // init() kutilmaydi — iOS'da APNs token bir necha soniya kelishi mumkin,
  // uni kutish ilova ochilishini sun'iy ravishda sekinlashtiradi.
  final push = Get.put(PushNotificationService(), permanent: true);
  unawaited(push.init());

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
      translations: AppTranslations(),
      locale: AppTranslations.localeFromCode(LocalStorage().language),
      fallbackLocale: AppTranslations.fallback,
      initialRoute: AppRoutes.initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
