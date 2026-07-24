import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications foreground'da bildirishnoma ko'rsata olishi
    // uchun delegate ro'yxatdan o'tkaziladi. FlutterAppDelegate uni FCM'ga
    // uzatadi, shuning uchun push'lar ham to'g'ri yetib boradi.
    UNUserNotificationCenter.current().delegate = self

    // APNs token'siz FirebaseMessaging.getToken() xato beradi.
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
