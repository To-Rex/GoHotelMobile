import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/translations/app_translations.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/services/data_service.dart';
import '../../../data/services/push_notification_service.dart';

class AuthController extends GetxController {
  final storage = LocalStorage();
  final _dataService = DataService();

  final phoneController = ''.obs;
  final passwordController = ''.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final selectedLanguage = 'UZ'.obs;
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedData();
  }

  void loadSavedData() {
    rememberMe.value = storage.rememberMe;
    selectedLanguage.value = storage.language;
    if (storage.rememberMe) {
      phoneController.value = storage.savedPhone;
    }
    isLoggedIn.value = storage.isLoggedIn;
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleRememberMe() => rememberMe.toggle();

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
    storage.language = lang;
    // Butun ilova tilini darhol almashtiradi.
    Get.updateLocale(AppTranslations.localeFromCode(lang));
  }

  Future<void> login() async {
    if (phoneController.value.isEmpty || passwordController.value.isEmpty) {
      Get.snackbar(
        'Xatolik'.tr,
        'Iltimos, foydalanuvchi nomi va parolni kiriting'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // FCM token login so'rovi bilan birga yuboriladi — backend uni shu
      // foydalanuvchiga darhol bog'laydi.
      final fcmToken = _currentFcmToken();

      final result = await _dataService.login(
        phoneController.value,
        passwordController.value,
        fcmToken: fcmToken,
      );

      storage.isLoggedIn = true;
      await storage.write('auth_token', result['access_token'] ?? '');
      await storage.write('refresh_token', result['refresh_token'] ?? '');

      try {
        final user = await _dataService.getCurrentUser();
        storage.userId = user.id;
        storage.userRole = user.role;
        storage.userName = user.name;
      } catch (_) {
        storage.userId = result['access_token'] ?? '';
        storage.userRole = 'Housekeeper';
        storage.userName = phoneController.value;
      }

      storage.rememberMe = rememberMe.value;
      if (rememberMe.value) {
        storage.savedPhone = phoneController.value;
      }

      isLoggedIn.value = true;
      Get.offAllNamed('/home');

      // Token login so'roviga ulgurmagan bo'lsa (masalan iOS'da APNs hali
      // tayyor emas edi) — uni alohida so'rov bilan bog'laymiz.
      await _syncPushToken(alreadySent: fcmToken != null);
    } catch (e) {
      Get.snackbar(
        'Xatolik'.tr,
        'Login ma\'lumotlari noto\'g\'ri yoki serverga ulanishda xatolik'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Push servisi ro'yxatdan o'tmagan (yoki init'i muvaffaqiyatsiz tugagan)
  /// bo'lishi mumkin — shuning uchun `null` qaytarish normal holat.
  String? _currentFcmToken() {
    if (!Get.isRegistered<PushNotificationService>()) return null;
    try {
      return PushNotificationService.to.currentToken;
    } catch (_) {
      return null;
    }
  }

  /// Login muvaffaqiyatli tugagach chaqiriladi. Bu bosqichdagi xatolik
  /// login oqimini to'xtatmasligi kerak.
  Future<void> _syncPushToken({required bool alreadySent}) async {
    if (!Get.isRegistered<PushNotificationService>()) return;
    try {
      // Token login body'sida ketgan bo'lsa, takroriy so'rov yubormaymiz.
      if (!alreadySent) {
        await PushNotificationService.to.registerToken();
      }
      // Ilova push orqali ochilgan, lekin login talab qilgan bo'lsa —
      // endi kutib turgan xabarni qayta ishlaymiz.
      PushNotificationService.to.consumePendingMessage();
    } catch (_) {}
  }

  Future<void> logout() async {
    // Token'ni auth header hali amal qilayotganda uzamiz.
    if (Get.isRegistered<PushNotificationService>()) {
      try {
        await PushNotificationService.to.unregisterToken();
      } catch (_) {}
    }

    storage.isLoggedIn = false;
    storage.userId = '';
    storage.write('auth_token', '');
    storage.write('refresh_token', '');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
