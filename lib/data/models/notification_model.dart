enum NotificationType { critical, newTask, problemAccepted, inventory, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? roomNumber;
  final DateTime timestamp;
  final bool isRead;
  final bool hasActions;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.roomNumber,
    required this.timestamp,
    this.isRead = false,
    this.hasActions = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        type: NotificationType.values.firstWhere((e) => e.name == json['type']),
        title: json['title'],
        message: json['message'],
        roomNumber: json['room_number'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['is_read'] ?? false,
        hasActions: json['has_actions'] ?? false,
      );

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? roomNumber,
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
    'timestamp': timestamp.toIso8601String(),
    'is_read': isRead,
    'has_actions': hasActions,
  };
}
