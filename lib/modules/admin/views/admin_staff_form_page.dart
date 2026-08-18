import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../data/models/staff_model.dart';
import '../controllers/admin_staff_controller.dart';

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEdit ? 'Xodimni tahrirlash'.tr : 'Yangi xodim'.tr,
          style: AppTextStyles.h2(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Ism'.tr),
            _textField(firstNameController, 'Ism'.tr),
            const SizedBox(height: 16),
            _label('Familiya'.tr),
            _textField(lastNameController, 'Familiya'.tr),
            const SizedBox(height: 16),
            if (!isEdit) ...[
              _label('Login'.tr),
              _textField(usernameController, 'Login (kamida 3 belgi)'.tr),
              const SizedBox(height: 16),
              _label('Parol'.tr),
              _textField(
                passwordController,
                'Parol (kamida 6 belgi)'.tr,
                obscure: true,
              ),
              const SizedBox(height: 16),
              // Filial bloki TO'LIQ Obx ichida — filiallar keyin yuklansa ham
              // tanlov paydo bo'ladi (aks holda ko'p filialli mehmonxonada
              // dropdown umuman chiqmay, xodim yaratib bo'lmas edi)
              Obx(() {
                if (controller.branches.length <= 1) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Filial'.tr),
                    _dropdown<String>(
                      value: branchId,
                      hint: 'Filialni tanlang'.tr,
                      items: controller.branches
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(
                                b.name,
                                style: AppTextStyles.bodyMd(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => branchId = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            _label('Telefon'.tr),
            _textField(phoneController, '+998 ...'),
            const SizedBox(height: 16),
            if (isEdit) ...[
              _label('Holat'.tr),
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
                onChanged: (v) => setState(() => status = v ?? 'ACTIVE'),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
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
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      return Pressable(
        onTap: submitting ? null : _submit,
        child: AnimatedContainer(
          duration: AppMotion.base,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: submitting
                  ? [AppColors.outlineVariant, AppColors.outlineVariant]
                  : const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: submitting
                ? null
                : AppShadows.glow(AppColors.primary, alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (submitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                Icon(
                  isEdit ? Icons.save_rounded : Icons.person_add_alt_rounded,
                  color: AppColors.onPrimary,
                ),
              const SizedBox(width: 8),
              Text(
                submitting
                    ? 'Saqlanmoqda...'.tr
                    : isEdit
                    ? 'Saqlash'.tr
                    : 'Xodim qo\'shish'.tr,
                style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
              ),
            ],
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
    // 422 o'rniga tushunarli mahalliy ogohlantirish
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
        // e'tiborsiz qoldirib, eski raqam qolib ketardi)
        phone: phone,
        status: status,
      );
      if (ok) Get.back();
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text;
    // Ko'p filialda tanlov MAJBURIY — jimgina birinchi filialga yozilmaydi
    final branch = branchId ??
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
