import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_roles.dart';

/// Boshqaruv (admin/menejer) shell'i: bo'lim holati va ruxsat tekshiruvi.
/// Navigatsiya drawer (yon menyu) orqali — farroshdagi bottom nav'dan farqli.
class AdminMainController extends GetxController {
  static const dashboardTab = 0;
  static const reservationsTab = 1;
  static const tasksTab = 2;
  static const roomsTab = 3;
  static const staffTab = 4;
  static const guestsTab = 5;
  static const problemsTab = 6;
  static const financeTab = 7;
  static const profileTab = 8;

  final _storage = LocalStorage();

  final currentIndex = 0.obs;

  /// Drawer ichki (sahifa) Scaffold'laridan ham ochilsin uchun global kalit.
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  /// Admin hamma amalni qila oladi, menejer — o'z ruxsatlari doirasida.
  bool can(String code) => AppRoles.can(
    code,
    userType: _storage.userType,
    permissions: _storage.userPermissions,
  );

  String get roleLabel => AppRoles.roleLabel(
    userType: _storage.userType,
    permissions: _storage.userPermissions,
  );

  String get userName => _storage.userName;
}
