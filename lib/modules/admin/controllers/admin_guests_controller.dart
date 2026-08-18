import 'package:get/get.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/reservation_model.dart';
import '../../../data/services/data_service.dart';

/// Mehmonlar ro'yxati (qidiruv bilan, faqat ko'rish).
class AdminGuestsController extends GetxController {
  final _dataService = DataService();

  final guests = <GuestLiteModel>[].obs;
  final query = ''.obs;

  /// Debounce qilingan qidiruv — har tugma bosilishida emas, yozish tingach
  /// filtrlanadi (katta bazada har harfda 1000 qatorni qayta qurish jank edi)
  final debouncedQuery = ''.obs;
  final isLoading = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan)
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    debounce(
      query,
      (String v) => debouncedQuery.value = v,
      time: const Duration(milliseconds: 250),
    );
    loadGuests();
  }

  Future<void> loadGuests() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await _dataService.getGuests();
      // Soft-delete qilingan mehmonlar ro'yxatda ko'rsatilmaydi
      guests.value = list.where((g) => !g.isDeleted).toList();
      guests.refresh();
    } catch (_) {
      errorMessage.value = loadErrorText();
    } finally {
      isLoading.value = false;
    }
  }

  List<GuestLiteModel> get filtered {
    final q = debouncedQuery.value.trim().toLowerCase();
    if (q.isEmpty) return guests;
    return guests
        .where(
          (g) =>
              g.name.toLowerCase().contains(q) ||
              (g.phone ?? '').toLowerCase().contains(q),
        )
        .toList();
  }
}
