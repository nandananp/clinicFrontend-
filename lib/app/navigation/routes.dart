import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../modules/auth/presentation/providers/auth_provider.dart';
import '../../modules/auth/presentation/view/login_screen.dart';
import '../../modules/auth/presentation/state/auth_state.dart';
import 'app_pages.dart';

/// GoRouter configuration with authentication guards.
/// Routes are protected by redirect logic that checks auth state.
///
/// IMPORTANT: the router is created ONCE. Auth state changes only
/// re-run the redirect (via refreshListenable). It must NOT use
/// ref.watch(authNotifierProvider), otherwise every state change
/// (AuthLoading, AuthError...) rebuilds the router and resets the
/// LoginScreen, which is why the error toast was not shown.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppPages.login,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider); // read, not watch
      final isAuthenticated = authState is AuthAuthenticated;
      final isOnLoginPage = state.matchedLocation == AppPages.login;

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isOnLoginPage) {
        return AppPages.login;
      }

      // Redirect to dashboard if authenticated and on login page
      if (isAuthenticated && isOnLoginPage) {
        return AppPages.dashboard;
      }

      return null;
    },
    routes: [
      // ─── Login ────────────────────────────────────────────────
      GoRoute(
        path: AppPages.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── Dashboard (placeholder for Phase 2) ─────────────────
      GoRoute(
        path: AppPages.dashboard,
        builder: (context, state) => const _DashboardPlaceholder(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
});

// ═══════════════════════════════════════════════════════════════════════
// Temporary Placeholders — will be replaced in Phase 2
// ═══════════════════════════════════════════════════════════════════════

/// Dashboard placeholder showing successful login confirmation.
class _DashboardPlaceholder extends ConsumerWidget {
  const _DashboardPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userName =
        authState is AuthAuthenticated ? authState.user.fullName : 'Doctor';
    final clinicName = authState is AuthAuthenticated
        ? authState.user.clinicName ?? 'Clinic'
        : 'Clinic';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: Color(0xFF369D96),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome text
              Text(
                'Welcome, $userName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF123D50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                clinicName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF369D96),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login successful! Dashboard coming in Phase 2.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7B8D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF369D96),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 404 page for unknown routes.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF123D50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7B8D),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppPages.login),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF369D96),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}