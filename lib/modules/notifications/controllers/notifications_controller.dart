import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/data_service.dart';
import '../../../data/services/push_notification_service.dart';
import '../../home/controllers/main_controller.dart';

class NotificationsController extends GetxController {
  final _dataService = DataService();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  /// Push orqali kelgan, lekin server ro'yxatida hali ko'rinmagan xabarlar.
  /// Backend yozuvni ulgurmasdan push yuborsa, `loadNotifications()` ularni
  /// o'chirib yubormasligi uchun shu yerda saqlanadi.
  final _pushOnly = <String, NotificationModel>{};
  static const _maxPushOnly = 30;

  @override
  void onInit() {
    super.onInit();
    // Push kelganda ro'yxat darhol yangilanishi uchun servisga ulanamiz.
    NotificationsInbox.bind(
      onNotification: onPushReceived,
      onOpenTab: openNotificationsTab,
    );
    loadNotifications();
  }

  @override
  void onClose() {
    NotificationsInbox.unbind();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final fromServer = await _dataService.getNotifications();
      final serverIds = fromServer.map((n) => n.id).toSet();

      // Server yetib olgan push'larni kuzatuvdan chiqaramiz.
      _pushOnly.removeWhere((id, _) => serverIds.contains(id));

      notifications.value = [..._pushOnly.values, ...fromServer];
      notifications.refresh();
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  /// FCM push'idan kelgan bildirishnomani ro'yxat boshiga qo'yadi.
  /// Server allaqachon shu id bilan bergan bo'lsa — o'rniga yozadi.
  void onPushReceived(NotificationModel notification) {
    final existing = notification.id.isEmpty
        ? -1
        : notifications.indexWhere((n) => n.id == notification.id);

    if (existing != -1) {
      notifications[existing] = notification;
    } else {
      if (notification.id.isNotEmpty) {
        _pushOnly[notification.id] = notification;
        if (_pushOnly.length > _maxPushOnly) {
          _pushOnly.remove(_pushOnly.keys.first);
        }
      }
      notifications.insert(0, notification);
    }
    notifications.refresh();

    // Backend'dagi to'liq yozuv bilan sinxronlash (id, has_actions va h.k.).
    loadNotifications();
  }

  void openNotificationsTab() {
    if (!Get.isRegistered<MainController>()) return;
    // Ichki sahifada turgan bo'lsak, avval asosiy ekranga qaytamiz.
    if (Get.currentRoute != '/home') {
      Get.until((route) => route.settings.name == '/home');
    }
    Get.find<MainController>().changeTab(2);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      // Push'dan kelgan nusxa ham belgilanadi, aks holda keyingi
      // loadNotifications() uni yana o'qilmagan holda qaytaradi.
      final pushCopy = _pushOnly[id];
      if (pushCopy != null) _pushOnly[id] = pushCopy.copyWith(isRead: true);
      _dataService.markNotificationAsRead(id);
    }
  }

  void markAllAsRead() {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifications.refresh();
    _pushOnly.updateAll((_, n) => n.copyWith(isRead: true));
    _dataService.markAllNotificationsAsRead();
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}
