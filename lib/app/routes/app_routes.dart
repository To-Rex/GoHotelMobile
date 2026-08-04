import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_page.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/bindings/main_binding.dart';
import '../../modules/home/views/main_page.dart';
import '../../modules/notifications/bindings/notifications_binding.dart';
import '../../modules/occupied_rooms/bindings/occupied_rooms_binding.dart';
import '../../modules/occupied_rooms/views/occupied_rooms_page.dart';
import '../../modules/tasks/bindings/tasks_binding.dart';
import '../../modules/tasks/views/room_details_page.dart';
import '../../modules/report/bindings/report_binding.dart';
import '../../modules/report/views/photo_report_page.dart';
import '../../modules/report/views/problem_report_page.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_page.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        TasksBinding(),
        HomeBinding(),
        NotificationsBinding(),
        ReportBinding(),
        ProfileBinding(),
      ],
    ),
    GetPage(
      name: '/room-details',
      page: () => const RoomDetailsPage(),
      bindings: [TasksBinding(), RoomDetailsBinding()],
    ),
    GetPage(
      name: '/occupied-rooms',
      page: () => const OccupiedRoomsPage(),
      binding: OccupiedRoomsBinding(),
    ),
    GetPage(
      name: '/photo-report',
      page: () => const PhotoReportPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: '/problem-report',
      page: () => const ProblemReportPage(),
      binding: ProblemReportBinding(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
  ];

  static String get initialRoute {
    final storage = LocalStorage();
    return storage.isLoggedIn ? '/home' : '/login';
  }
}
