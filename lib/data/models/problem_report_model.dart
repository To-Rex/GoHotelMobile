class ProblemReportModel {
  final String? id;
  final String title;
  final String category;
  final String description;
  final List<String> photoPaths;
  final String? roomNumber;
  final DateTime createdAt;

  ProblemReportModel({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    this.photoPaths = const [],
    this.roomNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProblemReportModel.fromJson(Map<String, dynamic> json) =>
      ProblemReportModel(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        description: json['description'],
        photoPaths: List<String>.from(json['photo_paths'] ?? []),
        roomNumber: json['room_number'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'photo_paths': photoPaths,
    'room_number': roomNumber,
    'created_at': createdAt.toIso8601String(),
  };
}
