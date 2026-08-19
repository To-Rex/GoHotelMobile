import 'package:get/get.dart';

/// GET /api/v1/finance/payments javobidagi PaymentResponse.
class PaymentModel {
  final String id;
  final String paymentNumber;
  final double amount;
  final String paymentMethod;
  final String paymentDate; // YYYY-MM-DD

  const PaymentModel({
    required this.id,
    this.paymentNumber = '',
    required this.amount,
    this.paymentMethod = 'CASH',
    this.paymentDate = '',
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as String? ?? '',
    paymentNumber: json['payment_number'] as String? ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    paymentMethod: json['payment_method'] as String? ?? 'CASH',
    paymentDate: json['payment_date'] as String? ?? '',
  );
}

/// GET /api/v1/expenses/ javobidagi element.
class ExpenseModel {
  final String id;
  final String title;
  final String? category;
  final double amount;
  final String paymentMethod;
  final String expenseDate; // YYYY-MM-DD
  final String? createdByName;

  const ExpenseModel({
    required this.id,
    required this.title,
    this.category,
    required this.amount,
    this.paymentMethod = 'CASH',
    this.expenseDate = '',
    this.createdByName,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String?,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    paymentMethod: json['payment_method'] as String? ?? 'CASH',
    expenseDate: json['expense_date'] as String? ?? '',
    createdByName: json['created_by_name'] as String?,
  );
}

/// GET /api/v1/shop/sales javobidagi element — moliya hisobotida faqat
/// PAID savdolar (to'lov sanasi bo'yicha) tushum sifatida hisoblanadi.
class ShopSaleModel {
  final String id;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String paidAt; // ISO datetime
  final String? guestName;
  final String? reservationNumber;
  final String? createdByName;
  final int itemsCount;

  /// Bo'lib to'lash bo'laklari: [{amount, payment_method}] (bo'lmasa bo'sh)
  final List<Map<String, dynamic>> payments;

  const ShopSaleModel({
    required this.id,
    required this.totalAmount,
    this.paymentMethod = 'CASH',
    this.status = 'PAID',
    this.paidAt = '',
    this.guestName,
    this.reservationNumber,
    this.createdByName,
    this.itemsCount = 0,
    this.payments = const [],
  });

  factory ShopSaleModel.fromJson(Map<String, dynamic> json) => ShopSaleModel(
    id: json['id'] as String? ?? '',
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    paymentMethod: json['payment_method'] as String? ?? 'CASH',
    status: json['status'] as String? ?? 'PAID',
    paidAt: json['paid_at'] as String? ?? '',
    guestName: json['guest_name'] as String?,
    reservationNumber: json['reservation_number'] as String?,
    createdByName: json['created_by_name'] as String?,
    itemsCount: (json['items'] as List<dynamic>?)?.length ?? 0,
    payments: (json['payments'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(),
  );

  /// Ro'yxatda ko'rsatiladigan sana (faqat kun qismi)
  String get paidDate => paidAt.split('T').first;
}

/// To'lov usuli yorlig'i (moliya sahifasi uchun).
String paymentMethodLabel(String method) {
  switch (method) {
    case 'CASH':
      return 'Naqd'.tr;
    case 'CREDIT_CARD':
    case 'DEBIT_CARD':
      return 'Karta'.tr;
    case 'BANK_TRANSFER':
      return 'O\'tkazma'.tr;
    case 'MOBILE_PAYMENT':
    case 'ONLINE':
      return 'Onlayn'.tr;
    case 'MIXED':
      return 'Aralash'.tr;
    default:
      return method;
  }
}
