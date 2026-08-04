enum TaskStatus { pending, inProgress, completed }

class TaskModel {
  final String id;
  final String roomNumber;
  final String floor;
  final String roomType;
  final String? guest;
  final String? guestStatus;
  final TaskStatus status;
  final int progress;
  final String? deadline;
  final String? note;
  final bool isUrgent;
  final List<ChecklistItem> checklist;

  TaskModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    this.guest,
    this.guestStatus,
    required this.status,
    this.progress = 0,
    this.deadline,
    this.note,
    this.isUrgent = false,
    this.checklist = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    roomNumber: json['room_number'],
    floor: json['floor'],
    roomType: json['room_type'],
    guest: json['guest'],
    guestStatus: json['guest_status'],
    status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
    progress: json['progress'] ?? 0,
    deadline: json['deadline'],
    note: json['note'],
    isUrgent: json['is_urgent'] ?? false,
    checklist:
        (json['checklist'] as List<dynamic>?)
            ?.map((e) => ChecklistItem.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'room_number': roomNumber,
    'floor': floor,
    'room_type': roomType,
    'guest': guest,
    'guest_status': guestStatus,
    'status': status.name,
    'progress': progress,
    'deadline': deadline,
    'note': note,
    'is_urgent': isUrgent,
    'checklist': checklist.map((e) => e.toJson()).toList(),
  };

  TaskModel copyWith({
    String? id,
    String? roomNumber,
    String? floor,
    String? roomType,
    String? guest,
    String? guestStatus,
    TaskStatus? status,
    int? progress,
    String? deadline,
    String? note,
    bool? isUrgent,
    List<ChecklistItem>? checklist,
  }) {
    return TaskModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      roomType: roomType ?? this.roomType,
      guest: guest ?? this.guest,
      guestStatus: guestStatus ?? this.guestStatus,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      isUrgent: isUrgent ?? this.isUrgent,
      checklist: checklist ?? this.checklist,
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  ChecklistItem copyWith({String? id, String? title, bool? isCompleted}) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'],
    title: json['title'],
    isCompleted: json['is_completed'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted,
  };
}
