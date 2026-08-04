import 'package:get/get.dart';

/// GET /api/v1/housekeeping/occupied-rooms javobidagi bitta element.
/// Farrosh uchun: xona hozir band, [expectedCheckout] da bo'shashi kutiladi.
class OccupiedRoomModel {
  final String roomId;
  final String roomNumber;
  final String roomStatus;
  final String? floorId;
  final String reservationId;
  final String reservationNumber;
  final String reservationStatus; // CHECKED_IN | CONFIRMED
  final String bookingType; // DAILY | HOURLY
  final String guestName;
  final String checkInDate;
  final String checkOutDate;

  /// Server mahalliy (mehmonxona) vaqtida, timezone belgisisiz yuboradi.
  final DateTime expectedCheckout;

  /// So'rov paytida serverda hisoblangan qiymat; kechikkan bo'lsa manfiy.
  final int minutesUntilCheckout;
  final bool isOverdue;

  const OccupiedRoomModel({
    required this.roomId,
    required this.roomNumber,
    required this.roomStatus,
    this.floorId,
    required this.reservationId,
    required this.reservationNumber,
    required this.reservationStatus,
    required this.bookingType,
    required this.guestName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.expectedCheckout,
    required this.minutesUntilCheckout,
    required this.isOverdue,
  });

  factory OccupiedRoomModel.fromJson(Map<String, dynamic> json) {
    return OccupiedRoomModel(
      roomId: json['room_id'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
      roomStatus: json['room_status'] as String? ?? '',
      floorId: json['floor_id'] as String?,
      reservationId: json['reservation_id'] as String? ?? '',
      reservationNumber: json['reservation_number'] as String? ?? '',
      reservationStatus: json['reservation_status'] as String? ?? '',
      bookingType: json['booking_type'] as String? ?? 'DAILY',
      guestName: json['guest_name'] as String? ?? '',
      checkInDate: json['check_in_date'] as String? ?? '',
      checkOutDate: json['check_out_date'] as String? ?? '',
      expectedCheckout:
          DateTime.tryParse(json['expected_checkout'] as String? ?? '') ??
          DateTime.now(),
      minutesUntilCheckout:
          (json['minutes_until_checkout'] as num?)?.toInt() ?? 0,
      isOverdue: json['is_overdue'] as bool? ?? false,
    );
  }

  /// CONFIRMED — mehmon hali kelmagan, xona bron qilingan.
  bool get isReserved => reservationStatus == 'CONFIRMED';

  bool get isHourly => bookingType == 'HOURLY';

  static const _months = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentyabr',
    'oktyabr',
    'noyabr',
    'dekabr',
  ];

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// "14:00" yoki boshqa kun bo'lsa "30-iyul, 14:00".
  String get checkoutLabel {
    final now = DateTime.now();
    final time =
        '${_two(expectedCheckout.hour)}:${_two(expectedCheckout.minute)}';
    final sameDay =
        expectedCheckout.year == now.year &&
        expectedCheckout.month == now.month &&
        expectedCheckout.day == now.day;
    if (sameDay) return time;
    return '${expectedCheckout.day}-${_months[expectedCheckout.month - 1].tr}, $time';
  }

  /// Qolgan/kechikkan daqiqani o'qishga qulay matnga aylantiradi:
  /// 45 → "45 daqiqa qoldi", -80 → "1 soat 20 daqiqa kechikdi".
  static String formatRemaining(int minutes) {
    final overdue = minutes < 0;
    final abs = minutes.abs();
    final String body;
    if (abs < 1) {
      return 'Hozir bo\'shaydi'.tr;
    } else if (abs < 60) {
      body = '$abs ${'daqiqa'.tr}';
    } else if (abs < 60 * 24) {
      final h = abs ~/ 60;
      final m = abs % 60;
      body = m == 0 ? '$h ${'soat'.tr}' : '$h ${'soat'.tr} $m ${'daqiqa'.tr}';
    } else {
      final d = abs ~/ (60 * 24);
      final h = (abs % (60 * 24)) ~/ 60;
      body = h == 0 ? '$d ${'kun'.tr}' : '$d ${'kun'.tr} $h ${'soat'.tr}';
    }
    return overdue ? '$body ${'kechikdi'.tr}' : '$body ${'qoldi'.tr}';
  }
}
