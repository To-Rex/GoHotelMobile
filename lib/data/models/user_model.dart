class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String userType;
  final String status;
  final String? hotelId;
  final String? branchId;
  final String? email;
  final String? phone;
  final String? lastLoginAt;
  final List<String> permissions;

  final String department;
  final String avatarUrl;
  final double rating;
  final int workHours;

  UserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    required this.userType,
    this.status = 'ACTIVE',
    this.hotelId,
    this.branchId,
    this.email,
    this.phone,
    this.lastLoginAt,
    this.permissions = const [],
    this.department = '',
    this.avatarUrl = '',
    this.rating = 0.0,
    this.workHours = 0,
  });

  String get name =>
      [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
  String get role => userType;
  String get displayName => name.isNotEmpty ? name : username;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    username: json['username'] ?? '',
    userType: json['user_type'] ?? '',
    status: json['status'] ?? 'ACTIVE',
    hotelId: json['hotel_id'],
    branchId: json['branch_id'],
    email: json['email'],
    phone: json['phone'],
    lastLoginAt: json['last_login_at'],
    permissions: List<String>.from(json['permissions'] ?? []),
    department: json['department'] ?? '',
    avatarUrl: json['avatar_url'] ?? '',
    rating: (json['rating'] ?? 0.0).toDouble(),
    workHours: json['work_hours'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'user_type': userType,
    'status': status,
    'hotel_id': hotelId,
    'branch_id': branchId,
    'email': email,
    'phone': phone,
    'last_login_at': lastLoginAt,
    'permissions': permissions,
    'department': department,
    'avatar_url': avatarUrl,
    'rating': rating,
    'work_hours': workHours,
  };
}
