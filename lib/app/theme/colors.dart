import 'package:flutter/material.dart';

abstract class AppColors {
  // Palitra WEB FRONTEND (Tailwind) bilan BIR XIL: ko'k primary (#2563EB),
  // oq kartalar, kulrang neytrallar va emerald/amber/red holat ranglari —
  // sayt va mobil ilova yagona tizim bo'lib ko'rinadi.
  static const Color surface = Color(0xFFF9FAFB); // gray-50 (sahifa foni)
  static const Color surfaceDim = Color(0xFFE5E7EB); // gray-200
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // kartalar
  static const Color surfaceContainerLow = Color(0xFFF3F4F6); // gray-100
  static const Color surfaceContainer = Color(0xFFE5E7EB); // gray-200
  static const Color surfaceContainerHigh = Color(0xFFDDE1E6);
  static const Color surfaceContainerHighest = Color(0xFFD1D5DB); // gray-300
  static const Color onSurface = Color(0xFF111827); // gray-900 (asosiy matn)
  static const Color onSurfaceVariant = Color(0xFF6B7280); // gray-500
  static const Color inverseSurface = Color(0xFF111827);
  static const Color inverseOnSurface = Color(0xFFF9FAFB);
  static const Color outline = Color(0xFF9CA3AF); // gray-400
  static const Color outlineVariant = Color(0xFFE5E7EB); // gray-200
  static const Color surfaceTint = Color(0xFF2563EB);

  static const Color primary = Color(0xFF2563EB); // blue-600 — web primary
  static const Color onPrimary = Color(0xFFFFFFFF);
  // Amal yuzalari onPrimary matn bilan ishlatiladi — to'q ko'k (blue-700)
  static const Color primaryContainer = Color(0xFF1D4ED8);
  static const Color onPrimaryContainer = Color(0xFFDBEAFE);
  static const Color inversePrimary = Color(0xFF93C5FD);

  static const Color secondary = Color(0xFF7C3AED); // violet-600 aksent
  static const Color onSecondary = Color(0xFFFFFFFF);
  // Gradient tugmalarda primaryContainer bilan juft ishlatiladi — webda
  // gradient YO'Q, shuning uchun bir xil to'q ko'k: tugmalar yaxlit ko'rinadi
  static const Color secondaryContainer = Color(0xFF1D4ED8);
  static const Color onSecondaryContainer = Color(0xFFDBEAFE);

  static const Color tertiary = Color(0xFFC2410C); // orange-700
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFEA580C); // orange-600
  static const Color onTertiaryContainer = Color(0xFFFFEDD5);

  static const Color error = Color(0xFFDC2626); // red-600
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2); // red-100
  static const Color onErrorContainer = Color(0xFF991B1B); // red-800

  // Holat ranglari (web bilan bir xil semantika)
  static const Color statusCleaned = Color(0xFF059669); // emerald-600
  static const Color statusCleanedBg = Color(0xFFD1FAE5); // emerald-100
  static const Color statusInProgress = Color(0xFFD97706); // amber-600
  static const Color statusInProgressBg = Color(0xFFFEF3C7); // amber-100
  static const Color statusPending = Color(0xFF6B7280); // gray-500
  static const Color statusPendingBg = Color(0xFFF3F4F6); // gray-100

  static const Color success = Color(0xFF059669);

  // Xona/bron holatlari — web dashboard va xonalar sahifasi bilan aynan
  // bir xil ranglar (bo'sh yashil, band qizil, band qilingan ko'k...)
  static const Color statusAvailable = Color(0xFF10B981); // emerald-500
  static const Color statusOccupied = Color(0xFFEF4444); // red-500
  static const Color statusReserved = Color(0xFF3B82F6); // blue-500
  static const Color statusCleaningRoom = Color(0xFFF59E0B); // amber-500
  static const Color statusMaintenance = Color(0xFFF97316); // orange-500
  static const Color statusInspection = Color(0xFFA855F7); // purple-500
  static const Color statusOutOfService = Color(0xFF9CA3AF); // gray-400
  static const Color statusViolet = Color(0xFF8B5CF6); // violet-500 (kutish)
}

/// Warm, low-contrast shadows give surfaces a consistent "morning window"
/// light direction without turning every card into a floating panel.
abstract class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.onSurface.withValues(alpha: 0.055),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get raised => [
    BoxShadow(
      color: AppColors.onSurface.withValues(alpha: 0.075),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow(Color color, {double alpha = 0.2}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
