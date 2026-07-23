import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

abstract class AppTextStyles {
  static TextStyle h1({Color? color}) => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.02 * 24,
    color: color ?? AppColors.onSurface,
  );

  static TextStyle h2({Color? color}) => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.01 * 20,
    color: color ?? AppColors.onSurface,
  );

  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: color ?? AppColors.onSurface,
  );

  static TextStyle bodyMd({Color? color, double? fontSize}) => GoogleFonts.inter(
    fontSize: fontSize ?? 14,
    fontWeight: FontWeight.w400,
    height: 20 / (fontSize ?? 14),
    color: color ?? AppColors.onSurface,
  );

  static TextStyle labelCaps({Color? color, double? fontSize}) => GoogleFonts.inter(
    fontSize: fontSize ?? 12,
    fontWeight: FontWeight.w600,
    height: 16 / (fontSize ?? 12),
    letterSpacing: 0.05 * (fontSize ?? 12),
    color: color ?? AppColors.onSurfaceVariant,
  );

  static TextStyle statusBadge({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    color: color ?? AppColors.onSurface,
  );

  static TextStyle roomNumber({Color? color}) => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: color ?? AppColors.primary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle display({Color? color, double? fontSize}) => GoogleFonts.inter(
    fontSize: fontSize ?? 40,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1,
    color: color ?? AppColors.onSurface,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
