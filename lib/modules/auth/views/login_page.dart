import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  FadeSlideIn(index: 0, child: _buildLogo()),
                  const SizedBox(height: 24),
                  FadeSlideIn(index: 2, child: _buildTitle()),
                  const SizedBox(height: 32),
                  FadeSlideIn(index: 4, child: _buildLoginForm(context)),
                  const SizedBox(height: 16),
                  FadeSlideIn(index: 6, child: _buildLanguageSwitcher()),
                  const SizedBox(height: 16),
                  FadeSlideIn(index: 7, child: _buildSupportInfo()),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryContainer, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.glow(AppColors.primary, alpha: 0.35),
      ),
      child: const Icon(
        Icons.cleaning_services_rounded,
        color: AppColors.onPrimary,
        size: 40,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(AppConstants.appName, style: AppTextStyles.display(fontSize: 30)),
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
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.raised,
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

  InputDecoration _inputDecoration({
    required String hint,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
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
  }

  Widget _buildPhoneField() {
    return TextField(
      onChanged: (v) => controller.phoneController.value = v,
      controller: TextEditingController(text: controller.phoneController.value),
      keyboardType: TextInputType.text,
      style: AppTextStyles.bodyLg(),
      decoration: _inputDecoration(
        hint: 'Foydalanuvchi nomi',
        prefixIcon: const Icon(Icons.person_outline_rounded,
            color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextField(
        onChanged: (v) => controller.passwordController.value = v,
        obscureText: !controller.isPasswordVisible.value,
        style: AppTextStyles.bodyLg(),
        decoration: _inputDecoration(
          hint: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: AppColors.onSurfaceVariant),
          suffixIcon: IconButton(
            onPressed: controller.togglePasswordVisibility,
            icon: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                key: ValueKey(controller.isPasswordVisible.value),
                color: AppColors.onSurfaceVariant,
              ),
            ),
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
            child: BouncyCheck(checked: controller.rememberMe.value, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: controller.toggleRememberMe,
          child: Text('Eslab qolish', style: AppTextStyles.bodyMd()),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(
      () => Pressable(
        onTap: controller.isLoading.value ? null : controller.login,
        child: AnimatedContainer(
          duration: AppMotion.base,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: controller.isLoading.value
                  ? [AppColors.outlineVariant, AppColors.outlineVariant]
                  : const [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: controller.isLoading.value
                ? null
                : AppShadows.glow(AppColors.primary, alpha: 0.35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isLoading.value)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              else
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.onPrimary),
              const SizedBox(width: 8),
              Text(
                controller.isLoading.value ? 'Kirish...' : 'Kirish',
                style: AppTextStyles.bodyLg(color: AppColors.onPrimary),
              ),
            ],
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
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Pressable(
              onTap: () => controller.setLanguage(lang),
              child: AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.emphasized,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  lang,
                  style: AppTextStyles.statusBadge(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
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

/// Sekin harakatlanuvchi ikki yumshoq rang dog'i — jonli, ammo xotirjam fon.
class _AmbientBackdrop extends StatefulWidget {
  const _AmbientBackdrop();

  @override
  State<_AmbientBackdrop> createState() => _AmbientBackdropState();
}

class _AmbientBackdropState extends State<_AmbientBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            colors: [AppColors.surfaceContainer, AppColors.surface],
          ),
        ),
        child: SizedBox.expand(),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        return DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Stack(
            children: [
              _blob(
                alignment: Alignment(0.9 + 0.2 * math.sin(t), -0.9 + 0.15 * math.cos(t)),
                color: AppColors.surfaceContainerHighest,
                size: 340,
              ),
              _blob(
                alignment: Alignment(-1.1 + 0.2 * math.cos(t * 0.8), 0.7 + 0.2 * math.sin(t * 0.8)),
                color: AppColors.surfaceContainer,
                size: 300,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blob({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
