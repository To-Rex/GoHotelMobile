import 'package:get/get.dart';

/// GET /api/v1/reservations/ javobidagi ReservationResponse (qisqartirilgan).
class ReservationModel {
  final String id;
  final String reservationNumber;
  final String guestId;
  final String roomId;
  final String bookingType; // DAILY|HOURLY
  final String checkInDate;
  final String checkOutDate;
  // Soatlik bronlarda aniq vaqt oralig'i shu maydonlardan olinadi
  final String checkInDatetime;
  final String checkOutDatetime;
  final String status;
  final String paymentStatus; // UNPAID|PARTIALLY_PAID|PAID
  final double totalAmount;
  final double paidAmount;
  final DateTime? createdAt;

  const ReservationModel({
    required this.id,
    this.reservationNumber = '',
    required this.guestId,
    required this.roomId,
    this.bookingType = 'DAILY',
    this.checkInDate = '',
    this.checkOutDate = '',
    this.checkInDatetime = '',
    this.checkOutDatetime = '',
    required this.status,
    this.paymentStatus = 'UNPAID',
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      ReservationModel(
        id: json['id'] as String? ?? '',
        reservationNumber: json['reservation_number'] as String? ?? '',
        guestId: json['guest_id'] as String? ?? '',
        roomId: json['room_id'] as String? ?? '',
        bookingType: json['booking_type'] as String? ?? 'DAILY',
        checkInDate: json['check_in_date'] as String? ?? '',
        checkOutDate: json['check_out_date'] as String? ?? '',
        checkInDatetime: json['check_in_datetime'] as String? ?? '',
        checkOutDatetime: json['check_out_datetime'] as String? ?? '',
        status: json['status'] as String? ?? 'PENDING',
        paymentStatus: json['payment_status'] as String? ?? 'UNPAID',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );

  // Backend faqat CONFIRMED bronni check-in qiladi (PENDING rad etiladi) —
  // tugma ham faqat shu holatda ko'rsatiladi
  bool get canCheckIn => status == 'CONFIRMED';
  bool get canCheckOut => status == 'CHECKED_IN';
  bool get isActive =>
      status == 'PENDING' || status == 'CONFIRMED' || status == 'CHECKED_IN';

  /// Ro'yxatda ko'rsatiladigan davr: kunlikda sanalar, soatlikda kun + vaqt
  /// oralig'i (ISO datetime'lardan olinadi — sana oralig'i soatlikda ma'nosiz)
  String get periodLabel {
    if (bookingType == 'HOURLY' &&
        checkInDatetime.length >= 16 &&
        checkOutDatetime.length >= 16) {
      final day = checkInDatetime.substring(0, 10);
      final inT = checkInDatetime.substring(11, 16);
      final outT = checkOutDatetime.substring(11, 16);
      return '$day  $inT – $outT';
    }
    return '$checkInDate → $checkOutDate';
  }

  static const statuses = [
    'PENDING',
    'CONFIRMED',
    'CHECKED_IN',
    'CHECKED_OUT',
    'CANCELLED',
    'NO_SHOW',
  ];

  static String statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Kutilmoqda'.tr;
      case 'CONFIRMED':
        return 'Tasdiqlangan'.tr;
      case 'CHECKED_IN':
        return 'Yashamoqda'.tr;
      case 'CHECKED_OUT':
        return 'Chiqib ketgan'.tr;
      case 'CANCELLED':
        return 'Bekor qilingan'.tr;
      case 'NO_SHOW':
        return 'Kelmagan'.tr;
      default:
        return status;
    }
  }

  static String paymentLabel(String paymentStatus) {
    switch (paymentStatus) {
      case 'PAID':
        return 'To\'langan'.tr;
      case 'PARTIALLY_PAID':
        return 'Qisman to\'langan'.tr;
      case 'UNPAID':
        return 'To\'lanmagan'.tr;
      default:
        return paymentStatus;
    }
  }
}

/// GET /api/v1/guests/ dan ism ko'rsatish uchun yetarli qisqa model.
class GuestLiteModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  // O'chirilgan (soft-delete) mehmonlar ro'yxatlarda ko'rsatilmaydi
  final bool isDeleted;

  const GuestLiteModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.phone,
    this.isDeleted = false,
  });

  factory GuestLiteModel.fromJson(Map<String, dynamic> json) => GuestLiteModel(
    id: json['id'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    phone: json['phone'] as String?,
    isDeleted: json['is_deleted'] as bool? ?? false,
  );

  String get name => '$firstName $lastName'.trim();
}
