import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/layout/layout.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../controllers/admin_main_controller.dart';

/// Boshqaruv navigatsiyasi aksenti — web frontend bilan bir xil ko'k primary,
/// faqat tanlangan yo'l va brend belgisida ishlatiladi.
const _adminNavigationAccent = AppColors.primary;

/// Drawer'ni ochadigan tugma — boshqaruv sahifalari sarlavhasida turadi.
/// Shell Scaffold'iga global kalit orqali murojaat qiladi, shu sabab
/// sahifaning o'z Scaffold'i ichida ham ishlayveradi.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.of(context).isExpanded) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: 'Boshqaruv'.tr,
      button: true,
      child: Tooltip(
        message: 'Boshqaruv'.tr,
        child: Pressable(
          haptic: false,
          onTap: () => Get.find<AdminMainController>().openDrawer(),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.58),
              ),
            ),
            child: const Icon(
              Icons.menu_rounded,
              size: 21,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Boshqaruv (admin/menejer) yon menyusi. Sirtlar tekis va sokin, faol
/// bo'lim esa faqat bitta aksent va ingichka belgi bilan ajralib turadi.
class AdminDrawer extends GetView<AdminMainController> {
  final bool embedded;
  final double? drawerWidth;

  const AdminDrawer({super.key, this.embedded = false, this.drawerWidth});

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              final index = controller.currentIndex.value;
              final entries = <Widget>[
                _groupLabel('ASOSIY'.tr),
                _item(
                  context,
                  Icons.dashboard_outlined,
                  Icons.dashboard_rounded,
                  'Boshqaruv paneli'.tr,
                  AdminMainController.dashboardTab,
                  index,
                ),
                _item(
                  context,
                  Icons.event_note_outlined,
                  Icons.event_note_rounded,
                  'Bronlar'.tr,
                  AdminMainController.reservationsTab,
                  index,
                ),
                _item(
                  context,
                  Icons.assignment_outlined,
                  Icons.assignment_rounded,
                  'Vazifalar'.tr,
                  AdminMainController.tasksTab,
                  index,
                ),
                _item(
                  context,
                  Icons.meeting_room_outlined,
                  Icons.meeting_room_rounded,
                  'Xonalar'.tr,
                  AdminMainController.roomsTab,
                  index,
                ),
                _routeItem(
                  context,
                  Icons.night_shelter_outlined,
                  'Band xonalar'.tr,
                  '/occupied-rooms',
                ),
                _routeItem(
                  context,
                  Icons.forum_outlined,
                  'Xabarlar taxtasi'.tr,
                  '/staff-messages',
                ),
                const SizedBox(height: 8),
                _groupLabel('ADMINISTRATSIYA'.tr),
                // Ruxsati bo'lmagan bo'limlar menejerlarga KO'RSATILMAYDI —
                // aks holda doim bo'sh sahifaga tushib qolar edi (403 ni
                // servis yutib yuboradi).
                if (controller.can('employee.view') ||
                    controller.can('employee.manage') ||
                    controller.can('employee.create'))
                  _item(
                    context,
                    Icons.groups_outlined,
                    Icons.groups_rounded,
                    'Xodimlar'.tr,
                    AdminMainController.staffTab,
                    index,
                  ),
                if (controller.can('guest.view'))
                  _item(
                    context,
                    Icons.person_search_outlined,
                    Icons.person_search_rounded,
                    'Mehmonlar'.tr,
                    AdminMainController.guestsTab,
                    index,
                  ),
                _item(
                  context,
                  Icons.report_problem_outlined,
                  Icons.report_problem_rounded,
                  'Muammolar'.tr,
                  AdminMainController.problemsTab,
                  index,
                ),
                if (controller.can('finance.view') ||
                    controller.can('report.view'))
                  _item(
                    context,
                    Icons.payments_outlined,
                    Icons.payments_rounded,
                    'Moliya'.tr,
                    AdminMainController.financeTab,
                    index,
                  ),
                const SizedBox(height: 8),
                _groupLabel('HISOB'.tr),
                _item(
                  context,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  'Profil'.tr,
                  AdminMainController.profileTab,
                  index,
                ),
              ];

              // Qisqa ro'yxat qasddan darhol chiziladi: har bir tab
              // almashganda qayta kaskad animatsiyasi ishga tushmaydi.
              return ListView(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                children: entries,
              );
            }),
          ),
          _buildLogout(context),
        ],
      ),
    );

    if (embedded) {
      return Material(color: AppColors.surfaceContainerLowest, child: content);
    }
    return Drawer(
      width: drawerWidth,
      elevation: 0,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;
        final markSize = compact ? 34.0 : 40.0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.48),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: markSize,
                height: markSize,
                decoration: BoxDecoration(
                  color: _adminNavigationAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: AppColors.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName.isEmpty
                          ? 'Go Hotel'
                          : controller.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.roleLabel.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _groupLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(
        text,
        style: AppTextStyles.labelCaps(
          color: AppColors.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    int tabIndex,
    int currentIndex,
  ) {
    final selected = tabIndex == currentIndex;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.fast;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 650),
        child: Pressable(
          haptic: false,
          pressedScale: 0.985,
          onTap: () {
            if (!embedded) Navigator.of(context).pop();
            controller.changeTab(tabIndex);
          },
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.emphasized,
            constraints: const BoxConstraints(minHeight: 48),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? _adminNavigationAccent.withValues(alpha: 0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected
                    ? _adminNavigationAccent.withValues(alpha: 0.10)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.emphasized,
                  width: 3,
                  height: selected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: _adminNavigationAccent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 7),
                AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.emphasized,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? _adminNavigationAccent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    selected ? filledIcon : outlineIcon,
                    color: selected
                        ? _adminNavigationAccent
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTextStyles.bodyMd(
                          color: selected
                              ? _adminNavigationAccent
                              : AppColors.onSurfaceVariant,
                        ).copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
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
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 650),
        child: Pressable(
          haptic: false,
          pressedScale: 0.985,
          onTap: () {
            if (!embedded) Navigator.of(context).pop();
            Get.toNamed(route);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 15,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Semantics(
          label: 'Hisobdan chiqish'.tr,
          button: true,
          child: Pressable(
            haptic: false,
            onTap: () => _confirmLogout(context),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Hisobdan chiqish'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.error,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    if (!embedded) Navigator.of(context).pop();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
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
              // ProfileController ro'yxatda bo'lmasa ham logout ISHLASHI shart.
              final profile = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>()
                  : Get.put(ProfileController());
              profile.logout();
            },
            child: Text(
              'Ha, chiqish'.tr,
              style: AppTextStyles.bodyMd(
                color: AppColors.error,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
