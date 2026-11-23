import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_pages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/patient_directory_entry.dart';
import '../presenter/patient_directory_presenter.dart';

class PatientDirectoryScreen extends ConsumerStatefulWidget {
  final List<PatientDirectoryEntry> patients;

  const PatientDirectoryScreen({super.key, this.patients = const []});

  @override
  ConsumerState<PatientDirectoryScreen> createState() =>
      _PatientDirectoryScreenState();
}

class _PatientDirectoryScreenState
    extends ConsumerState<PatientDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directoryState = widget.patients.isEmpty
        ? ref.watch(patientDirectoryPresenterProvider)
        : const AsyncData(<PatientDirectoryEntry>[]);
    final patients = widget.patients.isNotEmpty
        ? widget.patients
        : directoryState.asData?.value ?? const <PatientDirectoryEntry>[];
    final query = _searchController.text.trim().toLowerCase();
    final visiblePatients = patients.where((patient) {
      return patient.name.toLowerCase().contains(query) ||
          (patient.patientNumber?.toLowerCase().contains(query) ?? false) ||
          (patient.contactNumber?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppPages.dashboard),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to dashboard',
        ),
        title: const Text('Patients'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => context.push(AppPages.patientRegister),
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Register patient'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient directory',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Search and open patient records within your clinic.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by patient name or contact number',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: visiblePatients.isEmpty
                        ? _PatientEmptyState(
                            isSearching: query.isNotEmpty,
                            hasPatients: patients.isNotEmpty,
                            isLoading: directoryState.isLoading,
                            hasError: directoryState.hasError,
                            onRetry: () => ref
                                .read(
                                  patientDirectoryPresenterProvider.notifier,
                                )
                                .refresh(),
                          )
                        : ListView.separated(
                            itemCount: visiblePatients.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final patient = visiblePatients[index];
                              return Material(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 8,
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.primarySurface,
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    patient.name,
                                    style: const TextStyle(
                                      color: AppColors.heading,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (patient.patientNumber != null)
                                        'Patient No. ${patient.patientNumber}',
                                      if (patient.contactNumber != null)
                                        patient.contactNumber!,
                                    ].join('  •  '),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textLight,
                                  ),
                                  onTap: () => context.go(
                                    AppPages.consultationForPatient(patient.id),
                                    extra: patient,
                                  ),
                                ),
                              );
                            },
                          ),
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

class _PatientEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool hasPatients;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  const _PatientEmptyState({
    required this.isSearching,
    required this.hasPatients,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final title = isLoading
        ? 'Loading patients...'
        : hasError
        ? 'Unable to load patients'
        : isSearching
        ? 'No patients match your search'
        : hasPatients
        ? 'No patients found'
        : 'No patients registered yet';
    final message = isLoading
        ? 'Please wait while your clinic patient records load.'
        : hasError
        ? 'Check your connection and try loading the patient list again.'
        : isSearching
        ? 'Try another patient name, patient number or contact number.'
        : hasPatients
        ? 'The patient list is empty.'
        : 'Newly registered patients will appear here.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.heading,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 430,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
