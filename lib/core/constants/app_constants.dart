/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────────
  static const String appName = 'Clinic Management';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Electronic Medical Record System';

  // ─── Mock Credentials (Development Only) ──────────────────────────
  static const String mockUsername = 'doctor';
  static const String mockPassword = 'doctor123';
  static const String mockToken = 'mock_jwt_token_for_development';

  // ─── Secure Storage Keys ──────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // ─── Network Timeouts (ms) ────────────────────────────────────────
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ─── Pagination ───────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ─── UI Constants ─────────────────────────────────────────────────
  static const double sidebarExpandedWidth = 260.0;
  static const double sidebarCollapsedWidth = 80.0;
  static const double topbarHeight = 64.0;
  static const double cardBorderRadius = 16.0;
  static const double inputBorderRadius = 12.0;
  static const double buttonBorderRadius = 12.0;

  // ─── Breakpoints ──────────────────────────────────────────────────
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}
