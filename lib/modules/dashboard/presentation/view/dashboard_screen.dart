import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_pages.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../domain/entities/doctor_profile.dart';
import '../presenter/dashboard_presenter.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final fallbackName = authState is AuthAuthenticated
        ? authState.user.fullName
        : 'Doctor';
    final fallbackClinic = authState is AuthAuthenticated
        ? authState.user.clinicName ?? 'Clinic'
        : 'Clinic';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(
              child: _DashboardSidebar(
                activeItem: 'Dashboard',
                onLogout: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 248,
              child: _DashboardSidebar(
                activeItem: 'Dashboard',
                onLogout: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _DashboardHeader(
                  clinicName: fallbackClinic,
                  isDesktop: isDesktop,
                  onLogout: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                  onProfile: _loadDoctorProfile,
                  onRegisterPatient: () =>
                      context.push(AppPages.patientRegister),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 20,
                      28,
                      isDesktop ? 32 : 20,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WelcomeSection(
                              name: fallbackName,
                              clinicName: fallbackClinic,
                            ),
                            const SizedBox(height: 26),
                            const _DashboardOverview(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDoctorProfile() async {
    final profileState = ref.read(doctorProfilePresenterProvider);
    if (profileState.isLoading || profileState.asData?.value != null) return;
    try {
      await ref.read(doctorProfilePresenterProvider.notifier).loadProfile();
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : error.toString().replaceFirst('Exception:', '').trim();
      AppToast.showError(
        context,
        message,
        title: 'Unable to load doctor details',
      );
    }
  }
}

class _DashboardSidebar extends StatelessWidget {
  final String activeItem;
  final VoidCallback onLogout;

  const _DashboardSidebar({required this.activeItem, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 18, 30),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'myClinic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 0, 12),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            _SidebarItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              active: activeItem == 'Dashboard',
              onTap: () => context.go(AppPages.dashboard),
            ),
            _SidebarItem(
              icon: Icons.people_alt_outlined,
              label: 'Patients',
              onTap: () => context.go(AppPages.patients),
            ),
            _SidebarItem(
              icon: Icons.calendar_month_outlined,
              label: 'Appointments',
              onTap: () => context.go(AppPages.appointments),
            ),
            _SidebarItem(
              icon: Icons.medication_outlined,
              label: 'Medicines',
              onTap: () => context.go(AppPages.medicines),
            ),
            _SidebarItem(
              icon: Icons.receipt_long_outlined,
              label: 'Billing',
              onTap: () => context.go(AppPages.billing),
            ),
            const Spacer(),
            const Divider(color: Color(0x334D697A), height: 1),
            _SidebarItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.go(AppPages.settings),
            ),
            _SidebarItem(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              onTap: onLogout,
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: active ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: active ? Colors.white : AppColors.sidebarText,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.sidebarText,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String clinicName;
  final bool isDesktop;
  final VoidCallback onLogout;
  final Future<void> Function() onProfile;
  final VoidCallback onRegisterPatient;

  const _DashboardHeader({
    required this.clinicName,
    required this.isDesktop,
    required this.onLogout,
    required this.onProfile,
    required this.onRegisterPatient,
  });

  @override
  Widget build(BuildContext context) {
    final showRegisterLabel = MediaQuery.sizeOf(context).width >= 680;
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 18),
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(bottom: BorderSide(color: Color(0xFFD5EAE7))),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Open navigation',
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              clinicName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.heading,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tooltip(
            message: 'Register Patient',
            child: FilledButton.icon(
              onPressed: onRegisterPatient,
              icon: const Icon(Icons.person_add_alt_1, size: 17),
              label: showRegisterLabel
                  ? const Text('Register Patient')
                  : const SizedBox.shrink(),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: showRegisterLabel ? 16 : 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => AppToast.showInfo(
              context,
              'Notifications will be available when the dashboard API is ready.',
              title: 'Notifications',
            ),
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
          ),
          MenuAnchor(
            alignmentOffset: const Offset(0, 10),
            style: MenuStyle(
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              elevation: const WidgetStatePropertyAll(12),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            menuChildren: [_DoctorProfileMenu(onRetry: onProfile)],
            builder: (context, controller, child) => IconButton(
              onPressed: () {
                controller.open();
                onProfile();
              },
              tooltip: 'Doctor profile',
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primarySurface,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String name;
  final String clinicName;

  const _WelcomeSection({required this.name, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sidebar, AppColors.sidebarHover],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebar.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -82,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 34,
                ),
              ),
            ),
          ),
          Positioned(
            right: 150,
            bottom: -100,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primaryLight,
                            size: 13,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                Text(
                  'Good ${_greeting()}, '
                  '${name.trim().toLowerCase().startsWith('dr') ? name : 'Dr. $firstName'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here is your clinic overview for today.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 23),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryLight,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        clinicName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your clinic workspace at a glance',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.today_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Today',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            const gap = 14.0;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            final cards = [
              _OverviewCard(
                title: 'Patients',
                subtitle: 'Registered in your clinic',
                icon: Icons.people_alt_outlined,
                accent: AppColors.primary,
                tint: AppColors.primarySurface,
                onTap: () => context.go(AppPages.patients),
              ),
              _OverviewCard(
                title: 'Appointments',
                subtitle: 'Your clinic schedule',
                icon: Icons.calendar_month_outlined,
                accent: const Color(0xFF5977D8),
                tint: const Color(0xFFEEF2FF),
                onTap: () => context.go(AppPages.appointments),
              ),
              _OverviewCard(
                title: 'Billing',
                subtitle: 'Invoices and payments',
                icon: Icons.receipt_long_outlined,
                accent: const Color(0xFFD58A30),
                tint: const Color(0xFFFFF4E5),
                onTap: () => context.go(AppPages.billing),
              ),
              _OverviewCard(
                title: 'Medicines',
                subtitle: 'Clinic medicine catalogue',
                icon: Icons.medication_outlined,
                accent: const Color(0xFF8A61BC),
                tint: const Color(0xFFF4EDFA),
                onTap: () => context.go(AppPages.medicines),
              ),
            ];
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: cards
                  .map((card) => SizedBox(width: cardWidth, child: card))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        const _ActivityPanel(),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.heading.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: AppColors.textLight.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Ready to open',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Today at your clinic',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Daily activity and schedule',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinic activity will appear here',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Patient, appointment and billing summaries are ready to connect when their APIs are available.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Your clinic workspace is ready',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorProfileMenu extends ConsumerWidget {
  final Future<void> Function() onRetry;

  const _DoctorProfileMenu({required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(doctorProfilePresenterProvider);
    final profile = profileState.asData?.value;

    return SizedBox(
      width: 330,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: profileState.isLoading
            ? const _ProfileStatus(
                icon: Icons.hourglass_top_rounded,
                message: 'Loading doctor profile...',
              )
            : profileState.hasError || profile == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileStatus(
                    icon: Icons.person_off_outlined,
                    message: 'Doctor profile is unavailable.',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: const Text('Try again'),
                    ),
                  ),
                ],
              )
            : _DoctorProfileCard(profile: profile),
      ),
    );
  }
}

class _ProfileStatus extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ProfileStatus({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorProfileCard extends StatelessWidget {
  final DoctorProfile profile;

  const _DoctorProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.heading,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.designation ?? 'Doctor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 13),
        _ProfileDetail(
          icon: Icons.local_hospital_outlined,
          label: 'Clinic',
          value: profile.clinicName,
        ),
        const SizedBox(height: 10),
        _ProfileDetail(
          icon: Icons.auto_awesome_outlined,
          label: 'Specialization',
          value: profile.specialization ?? 'Not provided',
        ),
        const SizedBox(height: 10),
        _ProfileDetail(
          icon: Icons.phone_outlined,
          label: 'Contact',
          value: profile.contactNumber ?? 'Not provided',
        ),
      ],
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 9),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
