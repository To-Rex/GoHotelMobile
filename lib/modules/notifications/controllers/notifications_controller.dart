import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/data_service.dart';

class NotificationsController extends GetxController {
  final _dataService = DataService();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      notifications.value = await _dataService.getNotifications();
      notifications.refresh();
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      _dataService.markNotificationAsRead(id);
    }
  }

  void markAllAsRead() {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifications.refresh();
    _dataService.markAllNotificationsAsRead();
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}
