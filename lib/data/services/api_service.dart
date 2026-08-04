import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import '../models/occupied_room_model.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // ── AUTH ──────────────────────────────────────────────────────────

  /// [fcmToken] berilsa, backend uni shu foydalanuvchining qurilmasiga
  /// darhol bog'laydi — alohida device-token so'rovi kerak bo'lmaydi.
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? fcmToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'username': username,
        'password': password,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = response.data!;

    return {
      'access_token': data['access_token'],
      'refresh_token': data['refresh_token'],
      'token_type': data['token_type'] ?? 'bearer',
      'expires_in': data['expires_in'],
    };
  }

  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>('/api/v1/auth/me');
    return UserModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = response.data!;
    return {
      'access_token': data['access_token'],
      'refresh_token': data['refresh_token'],
      'token_type': data['token_type'] ?? 'bearer',
      'expires_in': data['expires_in'],
    };
  }

  // ── TASKS ─────────────────────────────────────────────────────────

  Future<List<TaskModel>> getTasks() async {
    final response = await _client.get<dynamic>('/api/v1/tasks');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getTask(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/tasks/$id',
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> startTask(String id) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/v1/tasks/$id/start',
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> updateTaskProgress(String id, int progress) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/v1/tasks/$id/progress',
      data: {'progress': progress},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> toggleChecklistItem(String taskId, String itemId) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/v1/tasks/$taskId/checklist/$itemId/toggle',
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> submitPhotoReport({
    required String taskId,
    required List<String> photoPaths,
    String? comment,
    Map<String, List<String>>? sectionMap,
  }) async {
    final formData = FormData();
    for (final path in photoPaths) {
      final file = File(path);
      formData.files.add(
        MapEntry(
          'photos',
          await MultipartFile.fromFile(
            path,
            filename: file.uri.pathSegments.last,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }
    if (comment != null) formData.fields.add(MapEntry('comment', comment));

    final response = await _client.post(
      '/api/v1/tasks/$taskId/report',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitProblemReport({
    String? taskId,
    required String category,
    required String description,
    required List<String> photoPaths,
    String? roomNumber,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('category', category));
    formData.fields.add(MapEntry('description', description));
    if (taskId != null) formData.fields.add(MapEntry('task_id', taskId));
    if (roomNumber != null)
      formData.fields.add(MapEntry('room_number', roomNumber));

    for (final path in photoPaths) {
      formData.files.add(
        MapEntry(
          'photos',
          await MultipartFile.fromFile(
            path,
            filename: File(path).uri.pathSegments.last,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    final response = await _client.post('/api/v1/problems', data: formData);
    return response.data as Map<String, dynamic>;
  }

  // ── HOUSEKEEPING ──────────────────────────────────────────────────

  /// Hozir band xonalar va ularning kutilayotgan chiqish vaqtlari.
  /// [includeReserved] true bo'lsa, hali kelmagan (CONFIRMED) bronlar ham qo'shiladi.
  Future<List<OccupiedRoomModel>> getOccupiedRooms({
    bool includeReserved = false,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/housekeeping/occupied-rooms',
      queryParameters: {'include_reserved': includeReserved},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => OccupiedRoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get<dynamic>('/api/v1/notifications/');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _client.put('/api/v1/notifications/$id/read');
  }

  Future<void> markAllNotificationsAsRead() async {
    await _client.put('/api/v1/notifications/read-all');
  }

  // ── PUSH TOKEN ────────────────────────────────────────────────────

  /// FCM token'ni joriy foydalanuvchiga bog'laydi.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _client.post(
      '/api/v1/notifications/device-token',
      data: {'token': token, 'platform': platform},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  /// Logout'da token'ni uzadi — boshqa foydalanuvchiga xabar ketmasligi uchun.
  Future<void> unregisterDeviceToken(String token) async {
    await _client.delete(
      '/api/v1/notifications/device-token',
      data: {'token': token},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  // ── PROFILE ───────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>('/api/v1/auth/me');
    return UserModel.fromJson(response.data!);
  }
}
