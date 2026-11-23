import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_pages.dart';
import '../../../../core/theme/app_colors.dart';

enum ClinicSection { appointments, medicines, billing, settings }

class ClinicSectionScreen extends StatelessWidget {
  final ClinicSection section;

  const ClinicSectionScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final config = _sectionConfig[section]!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppPages.dashboard),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to dashboard',
        ),
        title: Text(config.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  config.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(config.icon, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.emptyTitle,
                                  style: const TextStyle(
                                    color: AppColors.heading,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.emptyMessage,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This screen is ready for its backend integration. No sample or placeholder clinical records are shown.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _SectionConfig {
  final String title;
  final String description;
  final String emptyTitle;
  final String emptyMessage;
  final IconData icon;

  const _SectionConfig({
    required this.title,
    required this.description,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.icon,
  });
}

const _sectionConfig = {
  ClinicSection.appointments: _SectionConfig(
    title: 'Appointments',
    description: 'Review and manage your clinic schedule.',
    emptyTitle: 'Appointments will appear here',
    emptyMessage:
        'The appointment list and scheduling actions will be connected when the appointment API is available.',
    icon: Icons.calendar_month_outlined,
  ),
  ClinicSection.medicines: _SectionConfig(
    title: 'Medicines',
    description: 'Medication catalogue and prescription entry.',
    emptyTitle: 'Medicine catalogue is not connected',
    emptyMessage:
        'No medicines are listed until the medication catalogue API and its approved data are available.',
    icon: Icons.medication_outlined,
  ),
  ClinicSection.billing: _SectionConfig(
    title: 'Billing',
    description: 'Review patient invoices and payment status.',
    emptyTitle: 'Billing is ready for integration',
    emptyMessage:
        'Invoice creation, payment tracking and billing history will appear here when the billing APIs are available.',
    icon: Icons.receipt_long_outlined,
  ),
  ClinicSection.settings: _SectionConfig(
    title: 'Settings',
    description: 'Clinic and account preferences.',
    emptyTitle: 'Settings are not connected',
    emptyMessage:
        'Clinic configuration and account settings require their APIs and permission rules before they can be changed.',
    icon: Icons.settings_outlined,
  ),
};
