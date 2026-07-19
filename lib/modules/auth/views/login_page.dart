import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            colors: [AppColors.surfaceContainer, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildLoginForm(context),
                const SizedBox(height: 16),
                _buildLanguageSwitcher(),
                const SizedBox(height: 16),
                _buildSupportInfo(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: 0.05,
        child: const Icon(
          Icons.cleaning_services,
          color: AppColors.onPrimary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(AppConstants.appName, style: AppTextStyles.h1()),
        const SizedBox(height: 8),
        Text(
          'Mehmonxona xizmati boshqaruv tizimiga xush kelibsiz',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 12),
          _buildForgotPassword(),
          const SizedBox(height: 16),
          _buildRememberMe(),
          const SizedBox(height: 24),
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      onChanged: (v) => controller.phoneController.value = v,
      controller: TextEditingController(text: controller.phoneController.value),
      keyboardType: TextInputType.text,
      style: AppTextStyles.bodyLg(),
      decoration: InputDecoration(
        hintText: 'Foydalanuvchi nomi',
        hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextField(
        onChanged: (v) => controller.passwordController.value = v,
        obscureText: !controller.isPasswordVisible.value,
        style: AppTextStyles.bodyLg(),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
          suffixIcon: IconButton(
            onPressed: controller.togglePasswordVisibility,
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'PAROLNI UNUTDINGIZMI?',
          style: AppTextStyles.labelCaps(color: AppColors.primary, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Obx(
          () => GestureDetector(
            onTap: controller.toggleRememberMe,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: controller.rememberMe.value
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
                color: controller.rememberMe.value
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: controller.rememberMe.value
                  ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('Eslab qolish', style: AppTextStyles.bodyMd()),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : controller.login,
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Icon(Icons.arrow_forward),
          label: Text(
            controller.isLoading.value ? 'Kirish...' : 'Kirish',
            style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AppConstants.languages.map((lang) {
          final isActive = controller.selectedLanguage.value == lang;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => controller.setLanguage(lang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  lang,
                  style: AppTextStyles.bodyMd(
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSupportInfo() {
    return Text(
      'Qo\'llab-quvvatlash: ${AppConstants.supportPhone}',
      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
    );
  }
}
