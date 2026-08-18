import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
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

  // ── BOSHQARUV (admin/menejer) ─────────────────────────────────────

  Future<List<HkTaskModel>> getHkTasks({String? status}) async {
    try {
      return await _api.getHkTasks(status: status);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getHkTasks(status: status);
      }
      return [];
    }
  }

  /// Mutatsiyalar xatoni tashlaydi — controller foydalanuvchiga
  /// aniq xabar (masalan, 403 "ruxsat yo'q") ko'rsatishi uchun.
  /// Takroriy urinish faqat 401 (token yangilangan) holatida qilinadi.
  Future<T> _mutate<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      final was401 = e is DioException && e.response?.statusCode == 401;
      await _handleAuthError(e);
      if (was401 && _isTokenValid()) {
        return await call();
      }
      rethrow;
    }
  }

  Future<HkTaskModel> createHkTask({
    required String branchId,
    required String roomId,
    required String taskType,
    String priority = 'MEDIUM',
    String? assignedTo,
    String? notes,
    String? scheduledDate,
  }) {
    return _mutate(
      () => _api.createHkTask(
        branchId: branchId,
        roomId: roomId,
        taskType: taskType,
        priority: priority,
        assignedTo: assignedTo,
        notes: notes,
        scheduledDate: scheduledDate,
      ),
    );
  }

  Future<HkTaskModel> updateHkTaskStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _mutate(() => _api.updateHkTaskStatus(id, status, notes: notes));
  }

  Future<HkTaskModel> assignHkTask(String id, String assignedTo) {
    return _mutate(() => _api.assignHkTask(id, assignedTo));
  }

  Future<List<RoomModel>> getRooms() async {
    try {
      return await _api.getRooms();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getRooms();
      }
      return [];
    }
  }

  Future<RoomModel> updateRoomStatus(
    String roomId,
    String status, {
    String? notes,
  }) {
    return _mutate(() => _api.updateRoomStatus(roomId, status, notes: notes));
  }

  Future<List<FloorModel>> getFloors() async {
    try {
      return await _api.getFloors();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getFloors();
      }
      return [];
    }
  }

  Future<List<BranchModel>> getBranches() async {
    try {
      return await _api.getBranches();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getBranches();
      }
      return [];
    }
  }

  Future<List<StaffModel>> getEmployees() async {
    try {
      final staff = await _api.getEmployees(status: 'ACTIVE');
      return staff.where((s) => s.isActive).toList();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        final staff = await _api.getEmployees(status: 'ACTIVE');
        return staff.where((s) => s.isActive).toList();
      }
      return [];
    }
  }

  /// Xodimlar boshqaruvi uchun — barcha holatdagi (o'chirilmagan) xodimlar.
  Future<List<StaffModel>> getAllStaff() async {
    try {
      final staff = await _api.getEmployees();
      return staff.where((s) => !s.isDeleted).toList();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        final staff = await _api.getEmployees();
        return staff.where((s) => !s.isDeleted).toList();
      }
      return [];
    }
  }

  Future<StaffModel> createEmployee({
    required String branchId,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    String? phone,
    String? email,
  }) {
    return _mutate(
      () => _api.createEmployee(
        branchId: branchId,
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
        phone: phone,
        email: email,
      ),
    );
  }

  Future<StaffModel> updateEmployee(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    String? status,
  }) {
    return _mutate(
      () => _api.updateEmployee(
        id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        status: status,
      ),
    );
  }

  Future<List<ReservationModel>> getReservations({String? status}) async {
    try {
      return await _api.getReservations(status: status);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getReservations(status: status);
      }
      return [];
    }
  }

  Future<void> checkInReservation(String id) {
    return _mutate(() => _api.checkInReservation(id));
  }

  Future<void> checkOutReservation(String id) {
    return _mutate(() => _api.checkOutReservation(id));
  }

  Future<void> cancelReservation(String id, {String? reason}) {
    return _mutate(() => _api.cancelReservation(id, reason: reason));
  }

  Future<List<GuestLiteModel>> getGuests() async {
    try {
      return await _api.getGuests();
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getGuests();
      }
      return [];
    }
  }

  Future<List<ProblemModel>> getProblems({String? status}) async {
    try {
      return await _api.getProblems(status: status);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getProblems(status: status);
      }
      return [];
    }
  }

  Future<ProblemModel?> getProblemDetail(String id) async {
    try {
      return await _api.getProblemDetail(id);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        try {
          return await _api.getProblemDetail(id);
        } catch (_) {}
      }
      return null;
    }
  }

  Future<void> updateProblemStatus(String id, String status) {
    return _mutate(() => _api.updateProblemStatus(id, status));
  }

  Future<List<PaymentModel>> getPayments({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      return await _api.getPayments(dateFrom: dateFrom, dateTo: dateTo);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getPayments(dateFrom: dateFrom, dateTo: dateTo);
      }
      return [];
    }
  }

  Future<List<ExpenseModel>> getExpenses({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      return await _api.getExpenses(dateFrom: dateFrom, dateTo: dateTo);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getExpenses(dateFrom: dateFrom, dateTo: dateTo);
      }
      return [];
    }
  }

  Future<List<ShopSaleModel>> getShopSales({
    String? dateFrom,
    String? dateTo,
    String? status,
    String dateBy = 'paid',
  }) async {
    try {
      return await _api.getShopSales(
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
        dateBy: dateBy,
      );
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getShopSales(
          dateFrom: dateFrom,
          dateTo: dateTo,
          status: status,
          dateBy: dateBy,
        );
      }
      return [];
    }
  }

  // ── XODIMLAR XABARLARI ────────────────────────────────────────────

  Future<List<StaffMessageModel>> getStaffMessages({String? status}) async {
    try {
      return await _api.getStaffMessages(status: status);
    } catch (e) {
      await _handleAuthError(e);
      if (_isTokenValid()) {
        return await _api.getStaffMessages(status: status);
      }
      return [];
    }
  }

  Future<StaffMessageModel> createStaffMessage({
    required String body,
    String? roomId,
  }) {
    return _mutate(() => _api.createStaffMessage(body: body, roomId: roomId));
  }

  Future<StaffMessageModel> markStaffMessageDone(String id) {
    return _mutate(() => _api.markStaffMessageDone(id));
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
