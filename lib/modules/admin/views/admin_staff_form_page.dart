import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../data/models/staff_model.dart';
import '../controllers/admin_staff_controller.dart';
import 'widgets/admin_common.dart';

/// Xodim yaratish / tahrirlash formasi.
/// `Get.arguments` sifatida [StaffModel] kelsa — tahrirlash rejimi.
class AdminStaffFormPage extends StatefulWidget {
  const AdminStaffFormPage({super.key});

  @override
  State<AdminStaffFormPage> createState() => _AdminStaffFormPageState();
}

class _AdminStaffFormPageState extends State<AdminStaffFormPage> {
  final controller = Get.find<AdminStaffController>();

  StaffModel? editing;
  String? branchId;
  String status = 'ACTIVE';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool get isEdit => editing != null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is StaffModel) {
      editing = args;
      firstNameController.text = args.firstName;
      lastNameController.text = args.lastName;
      phoneController.text = args.phone ?? '';
      status = args.status;
    }
    if (controller.branches.length == 1) {
      branchId = controller.branches.first.id;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          isEdit ? 'Xodimni tahrirlash'.tr : 'Yangi xodim'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h2(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = adminPageGutterForWidth(constraints.maxWidth);
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 32),
              child: AdminContentConstraint(
                maxWidth: 920,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 24),
                  child: Obx(_buildForm),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    // MUHIM: Obx builder'i HAR QANDAY yo'lda kamida bitta observable o'qishi
    // shart — tahrirlash rejimida filial bloki chiqmasa ham ro'yxat shu yerda
    // o'qiladi, aks holda GetX "improper use" xatosini otadi.
    final branchCount = controller.branches.length;
    final fields = <Widget>[
      _field('Ism'.tr, _textField(firstNameController, 'Ism'.tr)),
      _field('Familiya'.tr, _textField(lastNameController, 'Familiya'.tr)),
      if (!isEdit) ...[
        _field(
          'Login'.tr,
          _textField(usernameController, 'Login (kamida 3 belgi)'.tr),
        ),
        _field(
          'Parol'.tr,
          _textField(
            passwordController,
            'Parol (kamida 6 belgi)'.tr,
            obscure: true,
          ),
        ),
        // Filiallar yuklanishi kechiksa ham form reaktiv tarzda tanlovni
        // ko'rsatadi; avvalgi yaratish oqimi aynan shu holatda saqlanadi.
        if (branchCount > 1)
          _field(
            'Filial'.tr,
            _dropdown<String>(
              value: branchId,
              hint: 'Filialni tanlang'.tr,
              items: controller.branches
                  .map(
                    (branch) => DropdownMenuItem(
                      value: branch.id,
                      child: Text(
                        branch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => branchId = value),
            ),
          ),
      ],
      _field('Telefon'.tr, _textField(phoneController, '+998 ...')),
      if (isEdit)
        _field(
          'Holat'.tr,
          _dropdown<String>(
            value: status,
            items: [
              DropdownMenuItem(
                value: 'ACTIVE',
                child: Text('Faol'.tr, style: AppTextStyles.bodyMd()),
              ),
              DropdownMenuItem(
                value: 'INACTIVE',
                child: Text('Faol emas'.tr, style: AppTextStyles.bodyMd()),
              ),
            ],
            onChanged: (value) => setState(() => status = value ?? 'ACTIVE'),
          ),
        ),
    ];

    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildIntro(),
          const SizedBox(height: 20),
          _AdminFormGrid(children: fields),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    final title = isEdit ? 'Xodim ma\'lumotlari'.tr : 'Jamoaga yangi xodim'.tr;
    final subtitle = isEdit
        ? 'Kerakli ma\'lumotlarni yangilang'.tr
        : 'Kirish va aloqa ma\'lumotlarini kiriting'.tr;
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 260;
        final icon = Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            isEdit ? Icons.manage_accounts_rounded : Icons.person_add_alt_1,
            color: AppColors.primary,
          ),
        );
        final copy = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyLg()),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: narrow ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        );
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft,
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, const SizedBox(height: 12), copy],
                )
              : Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Expanded(child: copy),
                  ],
                ),
        );
      },
    );
  }

  Widget _field(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_label(label), field],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(), style: AppTextStyles.labelCaps()),
  );

  Widget _textField(
    TextEditingController textController,
    String hint, {
    bool obscure = false,
  }) {
    return TextField(
      controller: textController,
      obscureText: obscure,
      style: AppTextStyles.bodyMd(),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: AppColors.surfaceContainerLowest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd(color: AppColors.outline),
                ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.onSurfaceVariant,
          ),
          borderRadius: BorderRadius.circular(14),
          dropdownColor: AppColors.surfaceContainerLowest,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final submitting = controller.isSubmitting.value;
      final label = submitting
          ? 'Saqlanmoqda...'.tr
          : isEdit
          ? 'Saqlash'.tr
          : 'Xodim qo\'shish'.tr;
      final foreground = submitting
          ? AppColors.onSurfaceVariant
          : AppColors.onPrimary;
      return Semantics(
        button: true,
        label: label,
        child: Pressable(
          onTap: submitting ? null : _submit,
          child: AnimatedContainer(
            duration: AppMotion.base,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: submitting
                  ? AppColors.surfaceContainerHigh
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: submitting
                    ? AppColors.outlineVariant.withValues(alpha: 0.7)
                    : AppColors.primary,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (submitting)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Icon(
                    isEdit ? Icons.save_rounded : Icons.person_add_alt_rounded,
                    color: foreground,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLg(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _submit() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    // Backend ism ham, familiya ham bo'sh bo'lmasligini talab qiladi —
    // 422 o'rniga tushunarli mahalliy ogohlantirish.
    if (firstName.isEmpty || lastName.isEmpty) {
      _warn('Ism va familiyani kiriting'.tr);
      return;
    }

    if (isEdit) {
      final ok = await controller.updateStaff(
        editing!.id,
        firstName: firstName,
        lastName: lastName,
        // Bo'sh qoldirilsa telefon O'CHIRILADI (null yuborilsa backend
        // e'tiborsiz qoldirib, eski raqam qolib ketardi).
        phone: phone,
        status: status,
      );
      if (ok) Get.back();
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text;
    // Ko'p filialda tanlov MAJBURIY — jimgina birinchi filialga yozilmaydi.
    final branch =
        branchId ??
        (controller.branches.length == 1 ? controller.branches.first.id : null);

    if (username.length < 3 || password.length < 6) {
      _warn('Login (3+) va parol (6+) majburiy'.tr);
      return;
    }
    if (branch == null) {
      _warn('Filialni tanlang'.tr);
      return;
    }

    final ok = await controller.createStaff(
      branchId: branch,
      firstName: firstName,
      lastName: lastName,
      username: username,
      password: password,
      phone: phone.isEmpty ? null : phone,
    );
    if (ok) Get.back();
  }

  void _warn(String message) {
    Get.snackbar(
      'Xatolik'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorContainer,
      colorText: AppColors.onErrorContainer,
    );
  }
}

/// Reflows the same form controls instead of creating separate desktop and
/// mobile form trees, so entered text and focus survive a window resize.
class _AdminFormGrid extends StatelessWidget {
  final List<Widget> children;

  const _AdminFormGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 600dp oynada 24dp chetlar qolganidan keyin forma ~552dp bo'ladi;
        // shu sabab mavjud maydon kengligi 520dp ga yetganda ikki ustunga
        // o'tamiz. Qaror butun qurilma emas, amaldagi constraintga asoslanadi.
        final twoColumns = constraints.maxWidth >= 520;
        const gap = 16.0;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: 18,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
