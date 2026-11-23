import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../modules/auth/presentation/providers/auth_provider.dart';
import '../../modules/auth/presentation/view/login_screen.dart';
import '../../modules/auth/presentation/state/auth_state.dart';
import '../../modules/dashboard/presentation/view/clinic_section_screen.dart';
import '../../modules/dashboard/presentation/view/dashboard_screen.dart';
import '../../modules/patients/presentation/view/patient_directory_screen.dart';
import '../../modules/patients/presentation/view/patient_registration_screen.dart';
import '../../modules/patients/domain/entities/patient_directory_entry.dart';
import '../../modules/consultations/presentation/view/consultation_workspace_screen.dart';
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

  ref.listen<AuthState>(authNotifierProvider, (_, _) {
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

      // ─── Dashboard ────────────────────────────────────────────
      GoRoute(
        path: AppPages.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppPages.patientRegister,
        builder: (context, state) => const PatientRegistrationScreen(),
      ),
      GoRoute(
        path: AppPages.patients,
        builder: (context, state) => const PatientDirectoryScreen(),
      ),
      GoRoute(
        path: AppPages.appointments,
        builder: (context, state) =>
            const ClinicSectionScreen(section: ClinicSection.appointments),
      ),
      GoRoute(
        path: AppPages.patientConsultation,
        builder: (context, state) => ConsultationWorkspaceScreen(
          patientId: state.pathParameters['id']!,
          patient: state.extra is PatientDirectoryEntry
              ? state.extra! as PatientDirectoryEntry
              : null,
        ),
      ),
      GoRoute(
        path: AppPages.medicines,
        builder: (context, state) =>
            const ClinicSectionScreen(section: ClinicSection.medicines),
      ),
      GoRoute(
        path: AppPages.billing,
        builder: (context, state) =>
            const ClinicSectionScreen(section: ClinicSection.billing),
      ),
      GoRoute(
        path: AppPages.settings,
        builder: (context, state) =>
            const ClinicSectionScreen(section: ClinicSection.settings),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
});

// ═══════════════════════════════════════════════════════════════════════
// Shared route error view
// ═══════════════════════════════════════════════════════════════════════

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
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7B8D)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
