import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../controllers/admin_main_controller.dart';

/// Drawer'ni ochadigan tugma — boshqaruv sahifalari sarlavhasida turadi.
/// Shell Scaffold'iga global kalit orqali murojaat qiladi, shu sabab
/// sahifaning o'z Scaffold'i ichida ham ishlayveradi.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Get.find<AdminMainController>().openDrawer(),
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.soft,
        ),
        child: const Icon(
          Icons.menu_rounded,
          size: 22,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

/// Boshqaruv (admin/menejer) yon menyusi — web sidebar'iga o'xshash:
/// asosiy bo'limlar va "Administratsiya" guruhi.
class AdminDrawer extends GetView<AdminMainController> {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final index = controller.currentIndex.value;
                // Drawer har ochilganda elementlar chapdan kaskad bo'lib kiradi.
                final entries = <Widget>[
                  _groupLabel('ASOSIY'.tr),
                  _item(
                    context,
                    Icons.dashboard_rounded,
                    'Boshqaruv paneli'.tr,
                    AdminMainController.dashboardTab,
                    index,
                  ),
                  _item(
                    context,
                    Icons.event_note_rounded,
                    'Bronlar'.tr,
                    AdminMainController.reservationsTab,
                    index,
                  ),
                  _item(
                    context,
                    Icons.assignment_rounded,
                    'Vazifalar'.tr,
                    AdminMainController.tasksTab,
                    index,
                  ),
                  _item(
                    context,
                    Icons.meeting_room_rounded,
                    'Xonalar'.tr,
                    AdminMainController.roomsTab,
                    index,
                  ),
                  _routeItem(
                    context,
                    Icons.night_shelter_rounded,
                    'Band xonalar'.tr,
                    '/occupied-rooms',
                  ),
                  _routeItem(
                    context,
                    Icons.forum_rounded,
                    'Xabarlar taxtasi'.tr,
                    '/staff-messages',
                  ),
                  const SizedBox(height: 8),
                  _groupLabel('ADMINISTRATSIYA'.tr),
                  // Ruxsati bo'lmagan bo'limlar menejerlarga KO'RSATILMAYDI —
                  // aks holda doim bo'sh sahifaga tushib qolar edi (403 ni
                  // servis yutib yuboradi)
                  if (controller.can('employee.view') ||
                      controller.can('employee.manage') ||
                      controller.can('employee.create'))
                    _item(
                      context,
                      Icons.groups_rounded,
                      'Xodimlar'.tr,
                      AdminMainController.staffTab,
                      index,
                    ),
                  if (controller.can('guest.view'))
                    _item(
                      context,
                      Icons.person_search_rounded,
                      'Mehmonlar'.tr,
                      AdminMainController.guestsTab,
                      index,
                    ),
                  _item(
                    context,
                    Icons.report_problem_rounded,
                    'Muammolar'.tr,
                    AdminMainController.problemsTab,
                    index,
                  ),
                  if (controller.can('finance.view') ||
                      controller.can('report.view'))
                    _item(
                      context,
                      Icons.payments_rounded,
                      'Moliya'.tr,
                      AdminMainController.financeTab,
                      index,
                    ),
                  const SizedBox(height: 8),
                  _groupLabel('HISOB'.tr),
                  _item(
                    context,
                    Icons.person_rounded,
                    'Profil'.tr,
                    AdminMainController.profileTab,
                    index,
                  ),
                ];
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      FadeSlideIn(
                        index: i,
                        horizontal: true,
                        offset: 16,
                        duration: AppMotion.base,
                        child: entries[i],
                      ),
                  ],
                );
              }),
            ),
            _buildLogout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.glow(AppColors.primary, alpha: 0.25),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName.isEmpty
                      ? 'Go Hotel'
                      : controller.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    controller.roleLabel.tr,
                    style: AppTextStyles.labelCaps(color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(text, style: AppTextStyles.labelCaps()),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    int tabIndex,
    int currentIndex,
  ) {
    final selected = tabIndex == currentIndex;
    return Pressable(
      onTap: () {
        Navigator.of(context).pop();
        controller.changeTab(tabIndex);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: selected
                    ? AppTextStyles.bodyLg(color: AppColors.primary)
                    : AppTextStyles.bodyMd(),
              ),
            ),
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _routeItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Pressable(
      onTap: () {
        Navigator.of(context).pop();
        Get.toNamed(route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            const SizedBox(width: 0),
            Icon(icon, size: 22, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMd())),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Pressable(
        onTap: () => _confirmLogout(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.errorContainer),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Hisobdan chiqish'.tr,
                style: AppTextStyles.bodyMd(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Navigator.of(context).pop();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hisobdan chiqish?'.tr, style: AppTextStyles.h2()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Yo\'q'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // ProfileController ro'yxatda bo'lmasa ham logout ISHLASHI shart
              final profile = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>()
                  : Get.put(ProfileController());
              profile.logout();
            },
            child: Text(
              'Ha, chiqish'.tr,
              style: AppTextStyles.bodyMd(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
