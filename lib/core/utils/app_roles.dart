/// Rol aniqlash qoidalari — backend bilan bir xil mantiq:
/// - ADMIN va SUPER_ADMIN har qanday ruxsat tekshiruvidan o'tadi;
/// - "Menejer" alohida user_type emas, balki boshqaruv ruxsatlariga ega
///   EMPLOYEE (backend ham shunday aniqlaydi: permission.assign /
///   shift.force_close egasi);
/// - boshqaruv belgisi bo'lmagan EMPLOYEE — farrosh (mavjud oqim).
class AppRoles {
  AppRoles._();

  // DIQQAT: housekeeping.task.* bu yerga KIRMAYDI — ular farrosh/texnik
  // xizmat shablonlarida ham bor (backend MANAGER_ASSIGNABLE_PATTERNS
  // bilan bir xil doira), aks holda oddiy texnik xodim "menejer" bo'lib
  // admin panelga tushib qoladi.
  static const _managerMarkers = [
    'permission.assign',
    'shift.force_close',
    'employee.manage',
    'employee.create',
    'report.view',
  ];

  static bool isAdminType(String userType) =>
      userType == 'ADMIN' || userType == 'SUPER_ADMIN';

  /// Admin yoki menejer — boshqaruv interfeysini ko'radi.
  static bool isManagement({
    required String userType,
    required List<String> permissions,
  }) {
    if (isAdminType(userType)) return true;
    return _managerMarkers.any(permissions.contains);
  }

  /// Bitta amal uchun ruxsat: admin hammasini qila oladi,
  /// menejer faqat o'z ruxsatlari doirasida.
  static bool can(
    String code, {
    required String userType,
    required List<String> permissions,
  }) {
    if (isAdminType(userType)) return true;
    return permissions.contains(code);
  }

  /// Ko'rsatish uchun rol nomi.
  static String roleLabel({
    required String userType,
    required List<String> permissions,
  }) {
    if (isAdminType(userType)) return 'Administrator';
    if (isManagement(userType: userType, permissions: permissions)) {
      return 'Menejer';
    }
    return 'Farrosh';
  }
}
