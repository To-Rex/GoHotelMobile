import 'package:get/get.dart';

enum NotificationType { critical, newTask, problemAccepted, inventory, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? roomNumber;

  /// Bildirishnoma bog'langan vazifa — "Borish" tugmasi shu orqali
  /// to'g'ridan-to'g'ri xona sahifasini ochadi.
  final String? taskId;
  final DateTime timestamp;
  final bool isRead;
  final bool hasActions;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.roomNumber,
    this.taskId,
    required this.timestamp,
    this.isRead = false,
    this.hasActions = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Hozir'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${'daqiqa oldin'.tr}';
    if (diff.inHours < 24) return '${diff.inHours} ${'soat oldin'.tr}';
    return '${diff.inDays} ${'kun oldin'.tr}';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        type: parseType(json['type']),
        title: json['title'],
        message: json['message'],
        roomNumber: json['room_number'],
        taskId: json['task_id'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['is_read'] ?? false,
        hasActions: json['has_actions'] ?? false,
      );

  /// Noma'lum yoki bo'sh turdagi qiymat kelsa `system`ga tushadi — push'dan
  /// kelgan `data` maydonlari server enum'iga har doim ham mos kelavermaydi.
  static NotificationType parseType(dynamic raw) {
    final name = raw?.toString();
    return NotificationType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => NotificationType.system,
    );
  }

  /// FCM push'ining `data` payload'idan model yasaydi.
  /// Server `notification` blokini yubormasa, sarlavha/matn ham `data`dan olinadi.
  factory NotificationModel.fromPush({
    required Map<String, dynamic> data,
    String? fallbackTitle,
    String? fallbackBody,
    String? fallbackId,
  }) {
    final rawTimestamp = data['timestamp']?.toString();
    return NotificationModel(
      id: (data['id'] ?? data['notification_id'] ?? fallbackId ?? '')
          .toString(),
      type: parseType(data['type']),
      title: (data['title'] ?? fallbackTitle ?? 'Yangi bildirishnoma')
          .toString(),
      message: (data['message'] ?? data['body'] ?? fallbackBody ?? '')
          .toString(),
      roomNumber: data['room_number']?.toString(),
      taskId: (data['task_id'] ?? data['taskId'])?.toString(),
      timestamp: DateTime.tryParse(rawTimestamp ?? '') ?? DateTime.now(),
      isRead: false,
      hasActions: data['has_actions']?.toString() == 'true',
    );
  }

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? roomNumber,
    String? taskId,
    DateTime? timestamp,
    bool? isRead,
    bool? hasActions,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      roomNumber: roomNumber ?? this.roomNumber,
      taskId: taskId ?? this.taskId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      hasActions: hasActions ?? this.hasActions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'room_number': roomNumber,
    'task_id': taskId,
    'timestamp': timestamp.toIso8601String(),
    'is_read': isRead,
    'has_actions': hasActions,
  };
}
