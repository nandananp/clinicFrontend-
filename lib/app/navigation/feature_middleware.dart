import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/auth/presentation/providers/auth_provider.dart';
import '../../modules/auth/presentation/state/auth_state.dart';
import 'app_pages.dart';

/// Navigation middleware / auth guards.
/// Provides redirect logic for route protection.
class FeatureMiddleware {
  FeatureMiddleware._();

  /// Determines if a redirect is needed based on auth state.
  /// Returns the redirect path or null if no redirect is needed.
  static String? authRedirect(Ref ref, String currentLocation) {
    final authState = ref.read(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;
    final isOnLoginPage = currentLocation == AppPages.login;

    // If not authenticated and not on login page → redirect to login
    if (!isAuthenticated && !isOnLoginPage) {
      return AppPages.login;
    }

    // If authenticated and on login page → redirect to dashboard
    if (isAuthenticated && isOnLoginPage) {
      return AppPages.dashboard;
    }

    // No redirect needed
    return null;
  }
}
