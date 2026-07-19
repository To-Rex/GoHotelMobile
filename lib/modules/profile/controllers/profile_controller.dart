import 'package:get/get.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/services/data_service.dart';

class ProfileController extends GetxController {
  final _dataService = DataService();
  final storage = LocalStorage();

  final selectedLanguage = 'UZ'.obs;
  var userName = ''.obs;
  var userRole = ''.obs;
  var userRating = 0.0.obs;
  var userWorkHours = 0.obs;
  var userPhone = ''.obs;
  var userDepartment = ''.obs;
  var userId = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = storage.language;
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final user = await _dataService.getProfile();
      userName.value = user.displayName;
      userRole.value = user.role;
      userRating.value = user.rating;
      userWorkHours.value = user.workHours;
      userPhone.value = user.phone ?? '';
      userDepartment.value = user.department;
      userId.value = user.id;
    } catch (e) {
      userName.value = storage.userName;
      userRole.value = storage.userRole;
    } finally {
      isLoading.value = false;
    }
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
    storage.language = lang;
  }

  void logout() {
    storage.isLoggedIn = false;
    storage.userId = '';
    storage.userRole = '';
    storage.userName = '';
    storage.write('auth_token', '');
    Get.offAllNamed('/login');
  }
}
