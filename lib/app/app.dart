import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_toast.dart';
import 'navigation/routes.dart';

/// Root application widget.
/// Wraps the app with ProviderScope (done in main.dart) and
/// MaterialApp.router with GoRouter.
class ClinicApp extends ConsumerWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // AppToast uses the root navigator overlay, so toasts still show
    // even when the screen that triggered them is gone.
    AppToast.navigatorKey = router.routerDelegate.navigatorKey;

    return MaterialApp.router(
      title: 'Clinic Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}