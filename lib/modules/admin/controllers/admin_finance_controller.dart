import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/services/data_service.dart';

/// Moliya hisoboti: ISTALGAN sana oralig'i uchun bron to'lovlari,
/// do'kon savdolari (PAID, to'lov sanasi bo'yicha) va xarajatlar.
/// Sof natija = to'lovlar + do'kon − xarajatlar (web dashboard bilan bir xil).
class AdminFinanceController extends GetxController {
  final _dataService = DataService();

  final payments = <PaymentModel>[].obs;
  final expenses = <ExpenseModel>[].obs;
  final shopSales = <ShopSaleModel>[].obs;
  final isLoading = false.obs;

  /// Tarmoq xatosi — eski davr raqamlari yangi davr natijasi deb
  /// o'qilmasligi uchun ko'rsatiladi
  final errorMessage = RxnString();

  /// Tanlangan davr (standart: so'nggi 7 kun)
  final rangeFrom = DateTime.now().subtract(const Duration(days: 6)).obs;
  final rangeTo = DateTime.now().obs;

  /// Faol preset: 0 = bugun, 6 = 7 kun, 29 = 30 kun, -1 = maxsus oraliq
  final presetDays = 6.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _pretty(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  /// Sarlavha ostida ko'rsatiladigan davr yorlig'i
  String get rangeLabel {
    final a = _pretty(rangeFrom.value);
    final b = _pretty(rangeTo.value);
    return a == b ? a : '$a — $b';
  }

  /// Tez tanlov: oxirgi [days] kun (0 — faqat bugun)
  void setPreset(int days) {
    presetDays.value = days;
    final now = DateTime.now();
    rangeFrom.value = now.subtract(Duration(days: days));
    rangeTo.value = now;
    loadData();
  }

  /// Kalendar orqali tanlangan istalgan oraliq
  void setCustomRange(DateTimeRange range) {
    presetDays.value = -1;
    rangeFrom.value = range.start;
    rangeTo.value = range.end;
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    // Preset rejimida davr har yuklashda BUGUNGA nisbatan qayta hisoblanadi —
    // ilova yarim tundan oshib ochiq qolsa "Bugun/7 kun" eskirib qolmasin
    if (presetDays.value >= 0) {
      final now = DateTime.now();
      rangeFrom.value = now.subtract(Duration(days: presetDays.value));
      rangeTo.value = now;
    }
    try {
      final from = _dateKey(rangeFrom.value);
      final to = _dateKey(rangeTo.value);
      final results = await Future.wait([
        _dataService.getPayments(dateFrom: from, dateTo: to),
        _dataService.getExpenses(dateFrom: from, dateTo: to),
        // Faqat to'langan savdolar, to'lov olingan sana bo'yicha —
        // bronga yozilib keyin to'langan savdo o'sha kun tushumiga tushadi
        _dataService.getShopSales(
          dateFrom: from,
          dateTo: to,
          status: 'PAID',
          dateBy: 'paid',
        ),
      ]);
      payments.value = results[0] as List<PaymentModel>;
      expenses.value = results[1] as List<ExpenseModel>;
      shopSales.value = results[2] as List<ShopSaleModel>;
      payments.refresh();
      expenses.refresh();
      shopSales.refresh();
    } catch (_) {
      errorMessage.value = loadErrorText();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Davr bo'yicha jamlar ──────────────────────────────────────────

  double get paymentsTotal => payments.fold(0, (sum, p) => sum + p.amount);

  double get shopTotal => shopSales.fold(0, (sum, s) => sum + s.totalAmount);

  double get totalIncome => paymentsTotal + shopTotal;

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  double get netResult => totalIncome - totalExpenses;

  /// To'lov usullari kesimi — bron to'lovlari va do'kon savdolari birga
  Map<String, double> get methodTotals {
    final m = <String, double>{};
    void add(String method, double v) {
      final label = paymentMethodLabel(method);
      m[label] = (m[label] ?? 0) + v;
    }

    for (final p in payments) {
      add(p.paymentMethod, p.amount);
    }
    for (final s in shopSales) {
      add(s.paymentMethod, s.totalAmount);
    }
    return m;
  }

  List<PaymentModel> get recentPayments => payments.take(10).toList();
  List<ExpenseModel> get recentExpenses => expenses.take(10).toList();
  List<ShopSaleModel> get recentSales => shopSales.take(10).toList();
}
