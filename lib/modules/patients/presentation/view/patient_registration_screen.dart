import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_pages.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../dashboard/domain/entities/doctor_profile.dart';
import '../../../dashboard/presentation/presenter/dashboard_presenter.dart';
import '../../domain/entities/patient_registration.dart';
import '../presenter/patient_directory_presenter.dart';
import '../presenter/patient_registration_presenter.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  ConsumerState<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends ConsumerState<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _contactNumber = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyNumber = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodGroup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoctorProfile());
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _contactNumber.dispose();
    _email.dispose();
    _address.dispose();
    _emergencyName.dispose();
    _emergencyNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(doctorProfilePresenterProvider);
    final patientState = ref.watch(patientRegistrationPresenterProvider);
    final profile = profileState.when(
      data: (value) => value,
      error: (_, _) => null,
      loading: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppPages.dashboard),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to dashboard',
        ),
        title: const Text('Register patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a patient',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the patient details to create a clinic record.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ClinicContextCard(
                    profile: profile,
                    isLoading: profileState.isLoading,
                    hasError: profileState.hasError,
                    onRetry: _loadDoctorProfile,
                  ),
                  const SizedBox(height: 18),
                  _FormSection(
                    title: 'Personal information',
                    subtitle: 'Basic patient identity and contact details.',
                    children: [
                      _FormRow(
                        children: [
                          _textField(
                            controller: _firstName,
                            label: 'First name',
                            requiredField: true,
                            validator: (value) =>
                                _required(value, 'First name'),
                          ),
                          _textField(
                            controller: _lastName,
                            label: 'Last name',
                            requiredField: true,
                            validator: (value) => _required(value, 'Last name'),
                          ),
                        ],
                      ),
                      _FormRow(children: [_dateField(context), _genderField()]),
                      _FormRow(
                        children: [
                          _textField(
                            controller: _contactNumber,
                            label: 'Contact number',
                            requiredField: true,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                _required(value, 'Contact number'),
                          ),
                          _textField(
                            controller: _email,
                            label: 'Email address',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      _FormRow(
                        children: [
                          _bloodGroupField(),
                          _textField(controller: _address, label: 'Address'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _FormSection(
                    title: 'Emergency contact',
                    subtitle: 'Optional contact details for emergencies.',
                    children: [
                      _FormRow(
                        children: [
                          _textField(
                            controller: _emergencyName,
                            label: 'Contact name',
                          ),
                          _textField(
                            controller: _emergencyNumber,
                            label: 'Contact number',
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: patientState.isLoading
                              ? null
                              : () => context.go(AppPages.dashboard),
                          child: const Text('Cancel'),
                        ),
                        FilledButton.icon(
                          onPressed: profile == null || patientState.isLoading
                              ? null
                              : () => _submit(profile),
                          icon: patientState.isLoading
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 18),
                          label: Text(
                            patientState.isLoading
                                ? 'Saving...'
                                : 'Create patient',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(DoctorProfile profile) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final dateOfBirth = _dateOfBirth;
    if (dateOfBirth == null) {
      AppToast.showWarning(
        context,
        'Select the patient date of birth.',
        title: 'Missing information',
      );
      return;
    }

    try {
      final message = await ref
          .read(patientRegistrationPresenterProvider.notifier)
          .register(
            PatientRegistration(
              clinicId: profile.clinicId,
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              dateOfBirth: dateOfBirth,
              gender: _gender!,
              contactNumber: _contactNumber.text.trim(),
              email: _optional(_email.text),
              address: _optional(_address.text),
              bloodGroup: _bloodGroup,
              emergencyContactName: _optional(_emergencyName.text),
              emergencyContactNumber: _optional(_emergencyNumber.text),
            ),
          );
      if (!mounted) return;
      AppToast.showSuccess(context, message, title: 'Patient registered');
      ref.invalidate(patientDirectoryPresenterProvider);
      context.go(AppPages.patients);
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(
        context,
        error is ApiException ? error.message : error.toString(),
        title: 'Patient registration failed',
      );
    }
  }

  Future<void> _loadDoctorProfile() async {
    if (!mounted) return;
    final profileState = ref.read(doctorProfilePresenterProvider);
    if (profileState.isLoading || profileState.asData?.value != null) return;
    try {
      await ref.read(doctorProfilePresenterProvider.notifier).loadProfile();
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(
        context,
        error is ApiException ? error.message : error.toString(),
        title: 'Unable to load clinic details',
      );
    }
  }

  Widget _dateField(BuildContext context) {
    return FormField<DateTime>(
      validator: (_) =>
          _dateOfBirth == null ? 'Date of birth is required' : null,
      builder: (field) {
        final value = _dateOfBirth;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              helpText: 'Select date of birth',
            );
            if (picked != null) {
              setState(() => _dateOfBirth = picked);
              field.didChange(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of birth *',
              hintText: 'Select date',
              errorText: field.errorText,
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
            ),
            child: Text(
              value == null ? 'Select date' : _formatDate(value),
              style: TextStyle(
                color: value == null
                    ? AppColors.textLight
                    : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _genderField() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: const InputDecoration(
        labelText: 'Gender *',
        prefixIcon: Icon(Icons.wc_outlined, size: 18),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      validator: (value) => value == null ? 'Select gender' : null,
      onChanged: (value) => setState(() => _gender = value),
    );
  }

  Widget _bloodGroupField() {
    const groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return DropdownButtonFormField<String>(
      initialValue: _bloodGroup,
      decoration: const InputDecoration(
        labelText: 'Blood group',
        prefixIcon: Icon(Icons.bloodtype_outlined, size: 18),
      ),
      items: groups
          .map((group) => DropdownMenuItem(value: group, child: Text(group)))
          .toList(),
      onChanged: (value) => setState(() => _bloodGroup = value),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool requiredField = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
      ),
      validator: validator,
    );
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? '$label is required' : null;
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ClinicContextCard extends StatelessWidget {
  final DoctorProfile? profile;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  const _ClinicContextCard({
    required this.profile,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registering patient under',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile?.clinicName ??
                      (isLoading
                          ? 'Loading clinic details...'
                          : hasError
                          ? 'Unable to load clinic details'
                          : 'Clinic details are required to register a patient'),
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (hasError)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.heading,
              fontSize: 15,
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
          const SizedBox(height: 20),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final List<Widget> children;

  const _FormRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 16),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 16),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}
