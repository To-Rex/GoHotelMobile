import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/storage/local_storage.dart';
import '../../firebase_options.dart';
import '../models/notification_model.dart';
import 'data_service.dart';

/// Ilova fon (background) yoki yopiq (terminated) holatida kelgan push.
///
/// Top-level funksiya bo'lishi SHART — Flutter uni alohida isolate'da
/// chaqiradi, shuning uchun `@pragma('vm:entry-point')` ham kerak.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Yangi isolate'da Firebase qaytadan ishga tushirilishi kerak.
  // Isolate qayta ishlatilgan bo'lsa duplicate-app xatosi chiqmasligi uchun tekshiramiz.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // Bu yerda UI yo'q — tizim `notification` blokli xabarni o'zi ko'rsatadi.
  // Faqat `data`-only push'lar uchun kelajakda lokal ishlov qo'shilishi mumkin.
  debugPrint('[Push] background: ${message.messageId} ${message.data}');
}

/// FCM push bildirishnomalarini boshqaradi:
/// ruxsat so'rash, token'ni backend'ga ro'yxatdan o'tkazish, foreground'da
/// lokal bildirishnoma ko'rsatish va bosilganda kerakli sahifaga o'tish.
class PushNotificationService extends GetxService {
  PushNotificationService({DataService? dataService})
    : _dataService = dataService ?? DataService();

  static PushNotificationService get to => Get.find<PushNotificationService>();

  final DataService _dataService;
  final _storage = LocalStorage();
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Android 8+ uchun "yuqori muhimlik" kanali — foreground'da heads-up
  /// bildirishnoma ko'rsatish uchun kerak. `id` AndroidManifest'dagi
  /// `default_notification_channel_id` meta-data bilan bir xil bo'lishi shart.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'gohotel_high_importance',
    'Muhim bildirishnomalar',
    description: 'Yangi vazifalar va shoshilinch xabarlar',
    importance: Importance.high,
  );

  /// Oxirgi olingan FCM token (backend'ga yuborilgani).
  final Rxn<String> token = Rxn<String>();

  /// Foydalanuvchi bildirishnomalarga ruxsat berganmi.
  final RxBool isAuthorized = false.obs;

  /// Push bosilganda o'tish kerak bo'lgan xabar — ilova hali to'liq
  /// yuklanmagan bo'lsa shu yerda saqlanib turadi.
  RemoteMessage? _pendingMessage;

  bool _initialized = false;

  Future<PushNotificationService> init() async {
    if (_initialized) return this;
    _initialized = true;

    try {
      await _initLocalNotifications();
      await requestPermission();
      await _setupForegroundPresentation();
      _attachListeners();
      await _syncToken();
      await _handleInitialMessage();
    } catch (e) {
      // Push ishlamasa ham ilova ishlashda davom etishi kerak.
      debugPrint('[Push] init failed: $e');
    }

    return this;
  }

  // ── SOZLASH ───────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Ruxsatni FirebaseMessaging.requestPermission() so'raydi,
        // bu yerda takroran so'ramaymiz.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _routeFromData(data);
        } catch (e) {
          debugPrint('[Push] payload parse failed: $e');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Android 13+ va iOS'da bildirishnoma ruxsatini so'raydi.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    isAuthorized.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    return isAuthorized.value;
  }

  /// iOS'da ilova ochiq turganda ham banner ko'rinsin.
  /// Android'da buni lokal bildirishnoma o'zi bajaradi.
  Future<void> _setupForegroundPresentation() async {
    if (!Platform.isIOS) return;
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _attachListeners() {
    // Ilova ochiq turganda kelgan xabar.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Fon'da turgan ilova push bosilib ochilganda.
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Token aylanganda (qayta o'rnatish, cache tozalanishi va h.k.).
    _messaging.onTokenRefresh.listen((newToken) {
      token.value = newToken;
      _logToken(newToken, reason: 'refresh');
      _persistAndRegister(newToken);
    });
  }

  // ── TOKEN ─────────────────────────────────────────────────────────

  /// FCM token'ni konsolga to'liq chiqaradi — Firebase Console'dan test push
  /// yuborish uchun shu qiymat nusxalanadi.
  void _logToken(String fcmToken, {required String reason}) {
    final platform = Platform.isIOS ? 'ios' : 'android';
    // debugPrint ishlatiladi: logcat uzun qatorlarni tashlab yubormasligi uchun
    // chiqishni throttle qiladi.
    debugPrint(
      '\n'
      '╔══════════════════════════════════════════════════════════\n'
      '║ FCM TOKEN ($platform · $reason)\n'
      '╟──────────────────────────────────────────────────────────\n'
      '║ $fcmToken\n'
      '╚══════════════════════════════════════════════════════════',
    );
  }

  Future<void> _syncToken() async {
    final fcmToken = await _fetchToken();
    if (fcmToken == null) return;
    token.value = fcmToken;
    _logToken(fcmToken, reason: 'sync');
    await _persistAndRegister(fcmToken);
  }

  Future<String?> _fetchToken() async {
    // iOS'da APNS token kelmasdan turib getToken() xato beradi.
    if (Platform.isIOS) {
      final apns = await _waitForApnsToken();
      if (apns == null) {
        debugPrint('[Push] APNS token olinmadi — FCM token so\'ralmaydi');
        return null;
      }
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[Push] getToken failed: $e');
      return null;
    }
  }

  /// APNS token darhol tayyor bo'lmaydi — bir necha marta qayta urinamiz.
  Future<String?> _waitForApnsToken({int attempts = 5}) async {
    for (var i = 0; i < attempts; i++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null) return apns;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  Future<void> _persistAndRegister(String fcmToken) async {
    await _storage.write('fcm_token', fcmToken);
    // Login qilinmagan bo'lsa backend token'ni foydalanuvchiga bog'lay olmaydi
    // — login'dan keyin AuthController registerToken()ni qayta chaqiradi.
    if (!_storage.isLoggedIn) return;
    await _dataService.registerDeviceToken(fcmToken);
  }

  /// Joriy FCM token — xotiradagi qiymat bo'lmasa, oxirgi saqlangani.
  /// Login so'roviga `fcm_token` sifatida qo'shish uchun ishlatiladi.
  /// iOS'da APNs hali tayyor bo'lmasa `null` qaytishi mumkin.
  String? get currentToken {
    final value = token.value ?? _storage.read<String>('fcm_token');
    return (value == null || value.isEmpty) ? null : value;
  }

  /// Login'dan keyin chaqiriladi — token allaqachon olingan bo'lsa uni
  /// backend'ga bog'laydi, bo'lmasa yangisini so'raydi.
  Future<void> registerToken() async {
    final existing = token.value ?? _storage.read<String>('fcm_token');
    if (existing != null && existing.isNotEmpty) {
      token.value = existing;
      _logToken(existing, reason: 'login');
      await _dataService.registerDeviceToken(existing);
      return;
    }
    await _syncToken();
  }

  /// Logout'da chaqiriladi — token backend'da o'chiriladi, shunda boshqa
  /// foydalanuvchining xabarlari bu qurilmaga kelmaydi.
  Future<void> unregisterToken() async {
    final existing = token.value ?? _storage.read<String>('fcm_token');
    if (existing == null || existing.isEmpty) return;
    await _dataService.unregisterDeviceToken(existing);
  }

  // ── XABARLARNI QAYTA ISHLASH ──────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('[Push] foreground: ${message.messageId} ${message.data}');
    _pushToInbox(message);

    // iOS'da bannerni setForegroundNotificationPresentationOptions() ko'rsatadi
    // — bu yerda lokal bildirishnoma qo'shsak, ikkita banner chiqadi.
    if (Platform.isAndroid) {
      await _showLocalNotification(message);
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[Push] opened: ${message.messageId}');
    _pushToInbox(message);
    _routeFromData(message.data);
  }

  /// Ilova butunlay yopiq bo'lganda push orqali ochilgan holat.
  Future<void> _handleInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial == null) return;
    _pendingMessage = initial;
    // Birinchi frame chizilgach yo'naltiramiz — aks holda navigator tayyor emas.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => consumePendingMessage(),
    );
  }

  /// Kutib turgan push bo'lsa uni qayta ishlaydi (masalan login'dan keyin).
  void consumePendingMessage() {
    final message = _pendingMessage;
    if (message == null) return;
    // Hali login qilinmagan bo'lsa xabarni saqlab turamiz — AuthController
    // login'dan keyin bu metodni qaytadan chaqiradi.
    if (!_storage.isLoggedIn) return;

    _pendingMessage = null;
    _pushToInbox(message);
    _routeFromData(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['message']?.toString();
    if (title == null && body == null) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      // 32-bit int chegarasidan oshmasligi uchun hashCode'ni cheklaymiz.
      id:
          (message.messageId ?? DateTime.now().toIso8601String()).hashCode &
          0x7fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  /// Kelgan push'ni ilova ichidagi bildirishnomalar ro'yxatiga qo'shadi,
  /// shunda pastki navigatsiyadagi qizil nuqta ham darhol yangilanadi.
  void _pushToInbox(RemoteMessage message) {
    final model = NotificationModel.fromPush(
      data: Map<String, dynamic>.from(message.data),
      fallbackTitle: message.notification?.title,
      fallbackBody: message.notification?.body,
      fallbackId: message.messageId,
    );
    NotificationsInbox.add(model);
  }

  // ── NAVIGATSIYA ───────────────────────────────────────────────────

  Future<void> _routeFromData(Map<String, dynamic> data) async {
    if (!_storage.isLoggedIn) return;

    final taskId = (data['task_id'] ?? data['taskId'])?.toString();
    if (taskId != null && taskId.isNotEmpty) {
      try {
        final task = await _dataService.getTask(taskId);
        Get.toNamed('/room-details', arguments: task);
        return;
      } catch (e) {
        debugPrint('[Push] task ochilmadi ($taskId): $e');
      }
    }

    // Aniq maqsad bo'lmasa — bildirishnomalar tab'iga o'tamiz.
    NotificationsInbox.openTab();
  }
}

/// `PushNotificationService` bilan `NotificationsController` orasidagi ko'prik.
///
/// Controller hali yaratilmagan (login sahifasi) bo'lishi mumkin, shuning uchun
/// bog'lanish `Get.isRegistered` tekshiruvi orqali yumshoq qilingan.
class NotificationsInbox {
  NotificationsInbox._();

  static void Function(NotificationModel)? _onNotification;
  static void Function()? _onOpenTab;

  static void bind({
    required void Function(NotificationModel) onNotification,
    required void Function() onOpenTab,
  }) {
    _onNotification = onNotification;
    _onOpenTab = onOpenTab;
  }

  static void unbind() {
    _onNotification = null;
    _onOpenTab = null;
  }

  static void add(NotificationModel notification) =>
      _onNotification?.call(notification);

  static void openTab() => _onOpenTab?.call();
}
