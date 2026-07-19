import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // ── AUTH ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'username': username,
        'password': password,
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
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> getTask(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/api/v1/tasks/$id');
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> startTask(String id) async {
    final response = await _client.put<Map<String, dynamic>>('/api/v1/tasks/$id/start');
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
      formData.files.add(MapEntry(
        'photos',
        await MultipartFile.fromFile(path,
            filename: file.uri.pathSegments.last,
            contentType: MediaType('image', 'jpeg')),
      ));
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
    if (roomNumber != null) formData.fields.add(MapEntry('room_number', roomNumber));

    for (final path in photoPaths) {
      formData.files.add(MapEntry(
        'photos',
        await MultipartFile.fromFile(path,
            filename: File(path).uri.pathSegments.last,
            contentType: MediaType('image', 'jpeg')),
      ));
    }

    final response = await _client.post(
      '/api/v1/problems',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
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

  // ── PROFILE ───────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>('/api/v1/auth/me');
    return UserModel.fromJson(response.data!);
  }
}
