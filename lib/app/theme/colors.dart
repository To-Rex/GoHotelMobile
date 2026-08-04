import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDbf5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);
  static const Color outline = Color(0xFF747686);
  static const Color outlineVariant = Color(0xFFC4C5D7);
  static const Color surfaceTint = Color(0xFF2151DA);

  static const Color primary = Color(0xFF0037B0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1D4ED8);
  static const Color onPrimaryContainer = Color(0xFFCAD3FF);
  static const Color inversePrimary = Color(0xFFB7C4FF);

  static const Color secondary = Color(0xFF0058BE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF2170E4);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);

  static const Color tertiary = Color(0xFF7F2500);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFA73400);
  static const Color onTertiaryContainer = Color(0xFFFFC9B7);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status colors
  static const Color statusCleaned = Color(0xFF166534);
  static const Color statusCleanedBg = Color(0xFFF0FDF4);
  static const Color statusInProgress = Color(0xFF9A3412);
  static const Color statusInProgressBg = Color(0xFFFFF7ED);
  static const Color statusPending = Color(0xFF6B7280);
  static const Color statusPendingBg = Color(0xFFF3F4F6);

  static const Color success = Color(0xFF16A34A);
}

/// Yumshoq ambient soyalar — chegarasiz chuqurlik (DESIGN.md: Level 1 / Level 2).
abstract class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.onSurface.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get raised => [
    BoxShadow(
      color: AppColors.onSurface.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color color, {double alpha = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
