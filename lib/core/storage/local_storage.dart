import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  final GetStorage _box = GetStorage();

  Future<void> init() async => await GetStorage.init();

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  // Auth
  bool get isLoggedIn => _box.read('is_logged_in') ?? false;
  set isLoggedIn(bool value) => _box.write('is_logged_in', value);

  String get userId => _box.read('user_id') ?? '';
  set userId(String value) => _box.write('user_id', value);

  String get userRole => _box.read('user_role') ?? '';
  set userRole(String value) => _box.write('user_role', value);

  String get userName => _box.read('user_name') ?? '';
  set userName(String value) => _box.write('user_name', value);

  // Language
  String get language => _box.read('language') ?? 'UZ';
  set language(String value) => _box.write('language', value);

  // Remember me
  bool get rememberMe => _box.read('remember_me') ?? false;
  set rememberMe(bool value) => _box.write('remember_me', value);

  String get savedPhone => _box.read('saved_phone') ?? '';
  set savedPhone(String value) => _box.write('saved_phone', value);
}
