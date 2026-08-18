import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Backend xatosini foydalanuvchiga tushunarli (o'zbekcha) matnga aylantiradi:
/// 403 — ruxsat yo'q; 422 — maydon xatolari ro'yxati (FastAPI list formati);
/// ma'lum inglizcha xabarlar — tarjima; qolganlari — detail yoki umumiy matn.
String apiErrorText(Object e) {
  if (e is DioException) {
    final code = e.response?.statusCode;
    if (code == 403) return 'Bu amal uchun ruxsatingiz yo\'q'.tr;
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is List) {
      // FastAPI 422: [{loc: [body, field], msg: ...}, ...] — xom blob emas,
      // maydon nomi bilan o'qiladigan qatorlar ko'rsatiladi
      final parts = <String>[];
      for (final item in detail) {
        if (item is Map) {
          final loc = item['loc'];
          final field =
              (loc is List && loc.isNotEmpty) ? loc.last.toString() : '';
          final msg = item['msg']?.toString() ?? '';
          if (msg.isNotEmpty) {
            parts.add(field.isEmpty ? msg : '$field: $msg');
          }
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
    if (detail is String && detail.isNotEmpty) {
      return _localizeKnown(detail);
    }
    if (code != null && code >= 500) {
      return 'Serverda xatolik. Birozdan so\'ng qayta urining.'.tr;
    }
  }
  return 'Amal bajarilmadi. Qayta urinib ko\'ring.'.tr;
}

/// Backenddan inglizcha keladigan tanish xabarlarni o'zbekchalashtirish
String _localizeKnown(String detail) {
  if (detail.startsWith('Cannot check in reservation')) {
    return 'Faqat tasdiqlangan bronni kirish qilish mumkin'.tr;
  }
  if (detail.startsWith('Room is not in RESERVED')) {
    return 'Xona "band qilingan" holatda emas — xona holatini tekshiring'.tr;
  }
  if (detail.contains('not yet arrived')) {
    return 'Kirish sanasi hali kelmagan'.tr;
  }
  if (detail.startsWith('Cannot check out')) {
    return 'Faqat yashab turgan bronni chiqish qilish mumkin'.tr;
  }
  return detail;
}

/// Ro'yxat yuklanmaganda ko'rsatiladigan umumiy xato matni
String loadErrorText() =>
    'Ma\'lumot yuklanmadi. Internetni tekshirib, qayta urining.'.tr;
