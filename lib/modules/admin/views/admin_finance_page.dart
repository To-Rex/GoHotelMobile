import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/models/finance_models.dart';
import '../controllers/admin_finance_controller.dart';
import 'widgets/admin_common.dart';
import 'widgets/admin_drawer.dart';

/// Moliya hisoboti: istalgan sana oralig'i, tushum tarkibi (bron to'lovlari +
/// do'kon savdolari), to'lov usullari kesimi va batafsil ro'yxatlar.
class AdminFinancePage extends GetView<AdminFinanceController> {
  const AdminFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Moliya'.tr,
              subtitle: 'Davr bo\'yicha hisobot'.tr,
              showAvatar: false,
              leading: const DrawerMenuButton(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.payments.isEmpty &&
                        controller.expenses.isEmpty &&
                        controller.shopSales.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRangeSelector(context),
                          const SizedBox(height: 16),
                          const AdminSkeletonList(count: 5, height: 100),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(index: 1, child: _buildRangeSelector(context)),
                        // Yuklash xatosi — ko'rinib turgan raqamlar eskirgan
                        // bo'lishi mumkinligi haqida ogohlantirish + retry
                        if (controller.errorMessage.value != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 18,
                                  color: AppColors.onErrorContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value!,
                                    style: AppTextStyles.bodyMd(
                                      color: AppColors.onErrorContainer,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: controller.loadData,
                                  child: Text('Qayta'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FadeSlideIn(index: 2, child: _buildHero()),
                        const SizedBox(height: 16),
                        FadeSlideIn(index: 3, child: _buildBreakdown()),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          index: 4,
                          child: _sectionTitle(
                            'So\'nggi to\'lovlar'.tr,
                            controller.payments.length,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPayments(),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          index: 5,
                          child: _sectionTitle(
                            'Do\'kon savdolari'.tr,
                            controller.shopSales.length,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildShopSales(),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          index: 6,
                          child: _sectionTitle(
                            'So\'nggi xarajatlar'.tr,
                            controller.expenses.length,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildExpenses(),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h2())),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ta',
            style: AppTextStyles.bodyMd(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ── Davr tanlash: tez presetlar + kalendar orqali istalgan oraliq ──

  Widget _buildRangeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(
              children: [
                _presetChip('Bugun'.tr, 0),
                const SizedBox(width: 8),
                _presetChip('7 kun'.tr, 6),
                const SizedBox(width: 8),
                _presetChip('30 kun'.tr, 29),
                const SizedBox(width: 8),
                _customChip(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                controller.rangeLabel,
                style: AppTextStyles.bodyMd(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetChip(String label, int days) {
    final active = controller.presetDays.value == days;
    return GestureDetector(
      onTap: () => controller.setPreset(days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMd(
            color: active ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _customChip(BuildContext context) {
    final active = controller.presetDays.value == -1;
    return GestureDetector(
      onTap: () => _pickRange(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: active ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Boshqa davr'.tr,
              style: AppTextStyles.bodyMd(
                color: active ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: controller.rangeFrom.value,
        end: controller.rangeTo.value,
      ),
      helpText: 'Davrni tanlang'.tr,
      saveText: 'Tanlash'.tr,
    );
    if (picked != null) controller.setCustomRange(picked);
  }

  // ── Davr natijasi: tushum / xarajat / sof natija ──

  Widget _buildHero() {
    final net = controller.netResult;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAVR NATIJASI'.tr,
            style: AppTextStyles.labelCaps(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _heroItem(
                  'Tushum'.tr,
                  controller.totalIncome,
                  AppColors.statusCleaned,
                ),
              ),
              Expanded(
                child: _heroItem(
                  'Xarajat'.tr,
                  controller.totalExpenses,
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _heroItem(
                  'Sof natija'.tr,
                  net,
                  net >= 0 ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tor ustunda katta summa qisqarib emas, o'zi kichrayib sig'adi
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedMoney(
            value: value,
            style: AppTextStyles.h2(color: color),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ── Tushum tarkibi: bron to'lovlari, do'kon, to'lov usullari ──

  Widget _buildBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TUSHUM TARKIBI'.tr,
            style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          _breakdownRow(
            Icons.hotel_rounded,
            'Bron to\'lovlari'.tr,
            controller.payments.length,
            controller.paymentsTotal,
            AppColors.primary,
          ),
          const SizedBox(height: 8),
          _breakdownRow(
            Icons.storefront_rounded,
            'Do\'kon savdolari'.tr,
            controller.shopSales.length,
            controller.shopTotal,
            AppColors.statusCleaned,
          ),
          const SizedBox(height: 8),
          _breakdownRow(
            Icons.trending_down_rounded,
            'Xarajatlar'.tr,
            controller.expenses.length,
            controller.totalExpenses,
            AppColors.error,
          ),
          if (controller.methodTotals.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                color: AppColors.surfaceContainerLow,
              ),
            ),
            Text(
              'TO\'LOV USULLARI'.tr,
              style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            ...controller.methodTotals.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        formatMoney(e.value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLg(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _breakdownRow(
    IconData icon,
    String label,
    int count,
    double total,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label · $count ta',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ),
        Flexible(
          child: Text(
            formatMoney(total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLg(color: color),
          ),
        ),
      ],
    );
  }

  // ── Ro'yxatlar ──

  Widget _buildPayments() {
    if (controller.recentPayments.isEmpty) {
      return _emptyRow('To\'lovlar yo\'q'.tr);
    }
    return Column(
      children: controller.recentPayments
          .map(
            (p) => _listRow(
              icon: Icons.arrow_downward_rounded,
              color: AppColors.statusCleaned,
              title: paymentMethodLabel(p.paymentMethod),
              subtitle: p.paymentDate,
              amount: '+${formatMoney(p.amount)}',
            ),
          )
          .toList(),
    );
  }

  Widget _buildShopSales() {
    if (controller.recentSales.isEmpty) {
      return _emptyRow('Do\'kon savdolari yo\'q'.tr);
    }
    return Column(
      children: controller.recentSales
          .map(
            (s) => _listRow(
              icon: Icons.storefront_rounded,
              color: AppColors.statusCleaned,
              title: s.guestName?.isNotEmpty == true
                  ? s.guestName!
                  : 'Do\'kon savdosi'.tr,
              subtitle:
                  '${s.paidDate} • ${paymentMethodLabel(s.paymentMethod)}'
                  '${s.itemsCount > 0 ? ' • ${s.itemsCount} ${'mahsulot'.tr}' : ''}',
              amount: '+${formatMoney(s.totalAmount)}',
            ),
          )
          .toList(),
    );
  }

  Widget _buildExpenses() {
    if (controller.recentExpenses.isEmpty) {
      return _emptyRow('Xarajatlar yo\'q'.tr);
    }
    return Column(
      children: controller.recentExpenses
          .map(
            (e) => _listRow(
              icon: Icons.arrow_upward_rounded,
              color: AppColors.error,
              title: e.title,
              subtitle:
                  '${e.expenseDate}${e.createdByName == null ? '' : ' • ${e.createdByName}'}',
              amount: '-${formatMoney(e.amount)}',
            ),
          )
          .toList(),
    );
  }

  Widget _emptyRow(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd(),
                ),
                Text(
                  subtitle,
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
          Flexible(
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLg(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
