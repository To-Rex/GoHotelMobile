import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/api_error_text.dart';
import '../../../data/models/reservation_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/services/data_service.dart';
import 'admin_dashboard_controller.dart';

/// Bronlar boshqaruvi: ro'yxat, check-in / check-out / bekor qilish.
class AdminReservationsController extends GetxController {
  final _dataService = DataService();

  final reservations = <ReservationModel>[].obs;
  final selectedStatus = ''.obs; // '' — hammasi
  final isLoading = false.obs;

  /// Tarmoq xatosi — bo'sh ro'yxatdan farqlash uchun (retry bilan ko'rsatiladi)
  final errorMessage = RxnString();

  /// Amal bajarilayotgan bronlar — tugmalar bloklanadi (dublikat so'rov yo'q)
  final busyIds = <String>{}.obs;

  /// Filtr tez almashtirilganda ESKI javob yangisini bosib qo'ymasligi uchun
  int _requestSeq = 0;

  /// Ko'rsatish uchun: xona raqami va mehmon ismi xaritalari.
  final roomNumbers = <String, String>{}.obs;
  final guestNames = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final seq = ++_requestSeq;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _dataService.getReservations(
          status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        ),
        _dataService.getRooms(),
        _dataService.getGuests(),
      ]);
      if (seq != _requestSeq) return; // eskirgan javob — tashlab yuboriladi
      reservations.value = results[0] as List<ReservationModel>;
      final rooms = results[1] as List<RoomModel>;
      final guests = results[2] as List<GuestLiteModel>;
      roomNumbers.value = {for (final r in rooms) r.id: r.roomNumber};
      guestNames.value = {for (final g in guests) g.id: g.name};
      reservations.refresh();
    } catch (_) {
      if (seq != _requestSeq) return;
      errorMessage.value = loadErrorText();
    } finally {
      if (seq == _requestSeq) isLoading.value = false;
    }
  }

  void changeFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    // Eski filtr natijasi ko'rinib turmasligi uchun darhol tozalanadi
    reservations.clear();
    loadData();
  }

  String roomNumberOf(ReservationModel r) => roomNumbers[r.roomId] ?? '—';
  String guestNameOf(ReservationModel r) => guestNames[r.guestId] ?? '';

  bool isBusy(String id) => busyIds.contains(id);

  Future<void> checkIn(ReservationModel r) =>
      _runAction(r, () => _dataService.checkInReservation(r.id),
          'Mehmon kirishi qayd etildi'.tr);

  Future<void> checkOut(ReservationModel r) =>
      _runAction(r, () => _dataService.checkOutReservation(r.id),
          'Mehmon chiqishi qayd etildi'.tr);

  Future<void> cancel(ReservationModel r, String reason) =>
      _runAction(r, () => _dataService.cancelReservation(r.id, reason: reason),
          'Bron bekor qilindi'.tr);

  /// Umumiy amal qobig'i: dublikat bosishdan himoya + yangilash + xabar
  Future<void> _runAction(
    ReservationModel r,
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (busyIds.contains(r.id)) return;
    busyIds.add(r.id);
    try {
      await action();
      await loadData();
      _refreshDashboard();
      _success(successMessage);
    } catch (e) {
      _showError(e);
    } finally {
      busyIds.remove(r.id);
    }
  }

  void _refreshDashboard() {
    if (Get.isRegistered<AdminDashboardController>()) {
      Get.find<AdminDashboardController>().loadData();
    }
  }

  void _success(String message) {
    Get.snackbar(
      'Muvaffaqiyatli!'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCleanedBg,
      colorText: AppColors.statusCleaned,
    );
  }

  void _showError(Object e) {
    Get.snackbar(
      'Xatolik'.tr,
      apiErrorText(e),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorContainer,
      colorText: AppColors.onErrorContainer,
    );
  }
}
