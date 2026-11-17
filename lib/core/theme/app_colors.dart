import 'package:flutter/material.dart';

/// Centralized color constants for the Clinic Management application.
/// All colors are derived from the approved design palette.
class AppColors {
  AppColors._();

  // ─── Primary Colors ───────────────────────────────────────────────
  static const Color primary = Color(0xFF369D96);
  static const Color primaryLight = Color(0xFF4DB8B0);
  static const Color primaryDark = Color(0xFF2A7D77);
  static const Color primarySurface = Color(0xFFE8F5F4);

  // ─── Text Colors ──────────────────────────────────────────────────
  static const Color heading = Color(0xFF123D50);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF6B7B8D);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Background Colors ────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF0F2F5);

  // ─── Sidebar Colors ───────────────────────────────────────────────
  static const Color sidebar = Color(0xFF123C4F);
  static const Color sidebarDark = Color(0xFF0D2E3D);
  static const Color sidebarActive = Color(0xFF369D96);
  static const Color sidebarText = Color(0xFFB8C7D4);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarHover = Color(0xFF1A5268);

  // ─── Status Colors ────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Border & Divider ─────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFF0F0F0);

  // ─── Neutral ──────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
}
