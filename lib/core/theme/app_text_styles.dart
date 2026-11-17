import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text styles using Poppins font.
/// All text styles reference [AppColors] for consistency.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.poppins();

  // ─── Headings ─────────────────────────────────────────────────────
  static TextStyle get heading1 => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.heading,
        height: 1.3,
      );

  static TextStyle get heading2 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.heading,
        height: 1.3,
      );

  static TextStyle get heading3 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.heading,
        height: 1.4,
      );

  static TextStyle get heading4 => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.heading,
        height: 1.4,
      );

  // ─── Body ─────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ─── Labels ───────────────────────────────────────────────────────
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ─── Buttons ──────────────────────────────────────────────────────
  static TextStyle get buttonLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      );

  static TextStyle get buttonMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      );

  static TextStyle get buttonSmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      );

  // ─── Caption ──────────────────────────────────────────────────────
  static TextStyle get caption => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.4,
      );

  // ─── Overline ─────────────────────────────────────────────────────
  static TextStyle get overline => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        height: 1.4,
      );
}
