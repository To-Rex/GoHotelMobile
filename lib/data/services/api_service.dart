import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import '../models/occupied_room_model.dart';
import '../models/branch_model.dart';
import '../models/finance_models.dart';
import '../models/hk_task_model.dart';
import '../models/problem_model.dart';
import '../models/reservation_model.dart';
import '../models/room_model.dart';
import '../models/staff_message_model.dart';
import '../models/staff_model.dart';
import '../../core/storage/local_storage.dart';
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

  // ── BOSHQARUV (admin/menejer) ─────────────────────────────────────

  Future<List<HkTaskModel>> getHkTasks({
    String? status,
    int limit = 200,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/housekeeping/tasks',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': limit,
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => HkTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HkTaskModel> createHkTask({
    required String branchId,
    required String roomId,
    required String taskType,
    String priority = 'MEDIUM',
    String? assignedTo,
    String? notes,
    String? scheduledDate,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/housekeeping/tasks',
      data: {
        'branch_id': branchId,
        'room_id': roomId,
        'task_type': taskType,
        'priority': priority,
        if (assignedTo != null && assignedTo.isNotEmpty)
          'assigned_to': assignedTo,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'scheduled_date': ?scheduledDate,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return HkTaskModel.fromJson(response.data!);
  }

  Future<HkTaskModel> updateHkTaskStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/housekeeping/tasks/$id/status',
      data: {
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return HkTaskModel.fromJson(response.data!);
  }

  Future<HkTaskModel> assignHkTask(String id, String assignedTo) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/housekeeping/tasks/$id/assign',
      data: {'assigned_to': assignedTo},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return HkTaskModel.fromJson(response.data!);
  }

  Future<List<RoomModel>> getRooms({int limit = 500}) async {
    final response = await _client.get<dynamic>(
      '/api/v1/rooms/',
      queryParameters: {'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RoomModel> updateRoomStatus(
    String roomId,
    String status, {
    String? notes,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/rooms/$roomId/status',
      data: {
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return RoomModel.fromJson(response.data!);
  }

  Future<List<FloorModel>> getFloors() async {
    final response = await _client.get<dynamic>('/api/v1/floors/');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => FloorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BranchModel>> getBranches() async {
    final response = await _client.get<dynamic>(
      '/api/v1/branches/',
      queryParameters: {'limit': 500},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StaffModel>> getEmployees({
    String? status,
    int limit = 500,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/employees/',
      queryParameters: {'status': ?status, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StaffModel> createEmployee({
    required String branchId,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    String? phone,
    String? email,
  }) async {
    final storage = LocalStorage();
    // hotel_id saqlanmagan bo'lsa YUBORILMAYDI — backend uni tokendan o'zi
    // aniqlaydi; bo'sh '' yuborilsa tushunarsiz 422 (UUID emas) qaytardi
    final hotelId = storage.hotelId;
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/employees/',
      data: {
        if (hotelId.isNotEmpty) 'hotel_id': hotelId,
        'branch_id': branchId,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'password': password,
        'phone': ?phone,
        'email': ?email,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return StaffModel.fromJson(response.data!);
  }

  Future<StaffModel> updateEmployee(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? status,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/v1/employees/$id',
      data: {
        'first_name': ?firstName,
        'last_name': ?lastName,
        'phone': ?phone,
        'status': ?status,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return StaffModel.fromJson(response.data!);
  }

  Future<List<ReservationModel>> getReservations({
    String? status,
    int limit = 500,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/reservations/',
      queryParameters: {'status': ?status, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> checkInReservation(String id) async {
    await _client.post('/api/v1/reservations/$id/check-in');
  }

  Future<void> checkOutReservation(String id) async {
    await _client.post('/api/v1/reservations/$id/check-out');
  }

  Future<void> cancelReservation(String id, {String? reason}) async {
    await _client.post(
      '/api/v1/reservations/$id/cancel',
      data: {'reason': ?reason},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<List<GuestLiteModel>> getGuests({int pageSize = 1000}) async {
    final response = await _client.get<dynamic>(
      '/api/v1/guests/',
      queryParameters: {'page_size': pageSize},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => GuestLiteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProblemModel>> getProblems({
    String? status,
    int limit = 200,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/problems',
      queryParameters: {'status': ?status, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ProblemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProblemModel> getProblemDetail(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/problems/$id',
    );
    return ProblemModel.fromJson(response.data!);
  }

  Future<void> updateProblemStatus(String id, String status) async {
    await _client.patch(
      '/api/v1/problems/$id/status',
      data: {'status': status},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<List<PaymentModel>> getPayments({
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/finance/payments',
      queryParameters: {'date_from': ?dateFrom, 'date_to': ?dateTo},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExpenseModel>> getExpenses({
    String? dateFrom,
    String? dateTo,
    int limit = 1000,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/expenses/',
      queryParameters: {
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'limit': limit,
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Do'kon savdolari — moliya hisobotida dateBy='paid' + status='PAID'
  /// bilan chaqiriladi (to'lov olingan kunga tushum sifatida tushadi).
  Future<List<ShopSaleModel>> getShopSales({
    String? dateFrom,
    String? dateTo,
    String? status,
    String dateBy = 'paid',
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/shop/sales',
      queryParameters: {
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'status': ?status,
        'date_by': dateBy,
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ShopSaleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── XODIMLAR XABARLARI ────────────────────────────────────────────

  Future<List<StaffMessageModel>> getStaffMessages({
    String? status,
    int limit = 200,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/v1/messages/',
      queryParameters: {'status': ?status, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => StaffMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StaffMessageModel> createStaffMessage({
    required String body,
    String? roomId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/messages/',
      data: {'body': body, 'room_id': ?roomId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return StaffMessageModel.fromJson(response.data!);
  }

  Future<StaffMessageModel> markStaffMessageDone(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/messages/$id/done',
    );
    return StaffMessageModel.fromJson(response.data!);
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
