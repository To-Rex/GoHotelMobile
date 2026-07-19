import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/services/data_service.dart';

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
  }

  Future<void> login() async {
    if (phoneController.value.isEmpty || passwordController.value.isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, foydalanuvchi nomi va parolni kiriting',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _dataService.login(
        phoneController.value,
        passwordController.value,
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
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Login ma\'lumotlari noto\'g\'ri yoki serverga ulanishda xatolik',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    storage.isLoggedIn = false;
    storage.userId = '';
    storage.write('auth_token', '');
    storage.write('refresh_token', '');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
