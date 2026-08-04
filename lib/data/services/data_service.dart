import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import '../models/occupied_room_model.dart';
import '../../core/storage/local_storage.dart';
import 'api_client.dart';
import 'api_service.dart';

class DataService {
  final ApiService _api;

  DataService({ApiClient? apiClient})
    : _api = ApiService(apiClient ?? ApiClient());

  Future<void> _handleAuthError(dynamic e) async {
    if (e is DioException && e.response?.statusCode == 401) {
      final storage = LocalStorage();
      final refreshToken = storage.read<String>('refresh_token');

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final result = await _api.refreshToken(refreshToken);
          await storage.write('auth_token', result['access_token'] ?? '');
          await storage.write('refresh_token', result['refresh_token'] ?? '');
          return;
        } catch (_) {}
      }

      storage.isLoggedIn = false;
      await storage.write('auth_token', '');
      await storage.write('refresh_token', '');
      Get.offAllNamed('/login');
    }
  }

  // ── AUTH ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? fcmToken,
  }) async {
    return await _api.login(username, password, fcmToken: fcmToken);
  }

  Future<UserModel> getCurrentUser() async {
    try {
      return await _api.getMe();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getMe();
      }
      throw Exception('Auth failed');
    }
  }

  bool _isTokenValid() {
    final storage = LocalStorage();
    final token = storage.read<String>('auth_token');
    return token != null && token.isNotEmpty;
  }

  void _logApiError(String method, dynamic e) {
    if (e is DioException && e.response != null) {
      print(
        '[DataService] $method failed: ${e.response?.statusCode} ${e.response?.data}',
      );
    } else {
      print('[DataService] $method failed: $e');
    }
  }

  // ── TASKS ─────────────────────────────────────────────────────────

  Future<List<TaskModel>> getTasks() async {
    try {
      return await _api.getTasks();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getTasks();
      }
      return [];
    }
  }

  Future<TaskModel> getTask(String id) async {
    try {
      return await _api.getTask(id);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getTask(id);
      }
      throw Exception('Auth failed');
    }
  }

  Future<void> startTask(String id) async {
    try {
      await _api.startTask(id);
    } catch (e) {
      print('[DataService] API startTask failed: $e');
    }
  }

  Future<void> updateTaskProgress(String id, int progress) async {
    try {
      await _api.updateTaskProgress(id, progress);
    } catch (e) {
      print('[DataService] API updateTaskProgress failed: $e');
    }
  }

  Future<void> toggleChecklistItem(String taskId, String itemId) async {
    try {
      await _api.toggleChecklistItem(taskId, itemId);
    } catch (e) {
      print('[DataService] API toggleChecklistItem failed: $e');
    }
  }

  // ── PHOTO REPORT ──────────────────────────────────────────────────

  Future<bool> submitPhotoReport({
    required String taskId,
    required List<String> photoPaths,
    String? comment,
  }) async {
    try {
      await _api.submitPhotoReport(
        taskId: taskId,
        photoPaths: photoPaths,
        comment: comment,
      );
      return true;
    } catch (e) {
      _logApiError('submitPhotoReport', e);
      return false;
    }
  }

  // ── PROBLEM REPORT ────────────────────────────────────────────────

  Future<bool> submitProblemReport({
    String? taskId,
    required String category,
    required String description,
    required List<String> photoPaths,
    String? roomNumber,
  }) async {
    try {
      await _api.submitProblemReport(
        taskId: taskId,
        category: category,
        description: description,
        photoPaths: photoPaths,
        roomNumber: roomNumber,
      );
      return true;
    } catch (e) {
      _logApiError('submitProblemReport', e);
      return false;
    }
  }

  // ── HOUSEKEEPING ──────────────────────────────────────────────────

  Future<List<OccupiedRoomModel>> getOccupiedRooms({
    bool includeReserved = false,
  }) async {
    try {
      return await _api.getOccupiedRooms(includeReserved: includeReserved);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getOccupiedRooms(includeReserved: includeReserved);
      }
      return [];
    }
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _api.getNotifications();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getNotifications();
      }
      return [];
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _api.markNotificationAsRead(id);
    } catch (e) {
      print('[DataService] API markNotificationAsRead failed: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _api.markAllNotificationsAsRead();
    } catch (e) {
      print('[DataService] API markAllNotificationsAsRead failed: $e');
    }
  }

  // ── PUSH TOKEN ────────────────────────────────────────────────────

  /// Backend hali bu endpoint'ni qo'llab-quvvatlamasa ham ilova buzilmasligi
  /// uchun xatolik faqat log'ga yoziladi.
  Future<bool> registerDeviceToken(String token) async {
    try {
      await _api.registerDeviceToken(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      return true;
    } catch (e) {
      await _handleAuthError(e);
      _logApiError('registerDeviceToken', e);
      return false;
    }
  }

  Future<bool> unregisterDeviceToken(String token) async {
    try {
      await _api.unregisterDeviceToken(token);
      return true;
    } catch (e) {
      _logApiError('unregisterDeviceToken', e);
      return false;
    }
  }

  // ── PROFILE ───────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    try {
      return await _api.getProfile();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getProfile();
      }
      throw Exception('Auth failed');
    }
  }
}
