import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_pages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../patients/domain/entities/patient_directory_entry.dart';

class ConsultationWorkspaceScreen extends StatefulWidget {
  final String patientId;
  final PatientDirectoryEntry? patient;

  const ConsultationWorkspaceScreen({
    super.key,
    required this.patientId,
    this.patient,
  });

  @override
  State<ConsultationWorkspaceScreen> createState() =>
      _ConsultationWorkspaceScreenState();
}

class _ConsultationWorkspaceScreenState
    extends State<ConsultationWorkspaceScreen> {
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _planController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicationController = TextEditingController();
  final _strengthController = TextEditingController();
  final _doseController = TextEditingController();
  final _routeController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prescriptionItems = <String>[];
  String? _encounterType;

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    _diagnosisController.dispose();
    _planController.dispose();
    _bloodPressureController.dispose();
    _temperatureController.dispose();
    _pulseController.dispose();
    _weightController.dispose();
    _medicationController.dispose();
    _strengthController.dispose();
    _doseController.dispose();
    _routeController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppPages.patients),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to patients',
        ),
        title: const Text('Consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _NotSavedBanner(),
                const SizedBox(height: 18),
                _ConsultationSection(
                  title: 'Encounter details',
                  description: 'Patient selected from the clinic directory.',
                  children: [
                    _formRow([
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Patient',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient?.name ?? 'Patient details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              [
                                if (widget.patient?.patientNumber != null)
                                  'No. ${widget.patient!.patientNumber}',
                                if (widget.patient?.contactNumber != null)
                                  widget.patient!.contactNumber!,
                                if (widget.patient == null) widget.patientId,
                              ].join('  •  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _encounterType,
                        decoration: const InputDecoration(
                          labelText: 'Encounter type',
                        ),
                        hint: const Text('Select encounter type'),
                        items: const [
                          DropdownMenuItem(
                            value: 'CLINIC',
                            child: Text('Clinic'),
                          ),
                          DropdownMenuItem(
                            value: 'HOME_VISIT',
                            child: Text('Home visit'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _encounterType = value),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                const _ConsultationSection(
                  title: 'Patient history',
                  description:
                      'Previous consultations, allergies and conditions.',
                  children: [
                    _HistoryPlaceholder(
                      icon: Icons.history_rounded,
                      title: 'Consultation history is not connected',
                      message:
                          'Historical visits will appear here when the patient history API is available.',
                    ),
                    SizedBox(height: 12),
                    _HistoryPlaceholder(
                      icon: Icons.warning_amber_rounded,
                      title: 'Allergies and conditions are not connected',
                      message:
                          'No clinical history is inferred. Review these details when the backend provides them.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ConsultationSection(
                  title: 'Vitals',
                  description:
                      'Optional measurements recorded by the clinician.',
                  children: [
                    _formRow([
                      _input(_bloodPressureController, 'Blood pressure'),
                      _input(_temperatureController, 'Temperature'),
                      _input(_pulseController, 'Pulse'),
                      _input(_weightController, 'Weight'),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                _ConsultationSection(
                  title: 'Clinical notes',
                  description:
                      'Enter clinician-authored details for this encounter.',
                  children: [
                    _input(
                      _symptomsController,
                      'Presenting symptoms',
                      lines: 3,
                    ),
                    _input(
                      _notesController,
                      'Examination and clinical notes',
                      lines: 5,
                    ),
                    _input(_diagnosisController, 'Diagnosis', lines: 2),
                    _input(_planController, 'Treatment plan', lines: 3),
                  ],
                ),
                const SizedBox(height: 16),
                _ConsultationSection(
                  title: 'Prescription',
                  description:
                      'Enter clinician-selected medication details; this draft is local until the prescription API is connected.',
                  children: [
                    _formRow([
                      _input(_medicationController, 'Medication name'),
                      _input(_strengthController, 'Strength'),
                    ]),
                    _formRow([
                      _input(_doseController, 'Dose'),
                      _input(_routeController, 'Route'),
                      _input(_frequencyController, 'Frequency'),
                    ]),
                    _formRow([
                      _input(_durationController, 'Duration'),
                      _input(_quantityController, 'Quantity'),
                    ]),
                    _input(_instructionsController, 'Instructions', lines: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _addPrescriptionItem,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add medication'),
                      ),
                    ),
                    if (_prescriptionItems.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      for (
                        var index = 0;
                        index < _prescriptionItems.length;
                        index++
                      )
                        ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(_prescriptionItems[index]),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go(AppPages.patients),
                        child: const Text('Back to patients'),
                      ),
                      FilledButton.icon(
                        onPressed: () => AppToast.showInfo(
                          context,
                          'Consultation data is not saved. The consultation API is not connected yet.',
                          title: 'Not saved',
                        ),
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save draft'),
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

  void _addPrescriptionItem() {
    final name = _medicationController.text.trim();
    if (name.isEmpty) {
      AppToast.showWarning(
        context,
        'Enter a medication name before adding it.',
        title: 'Medication name required',
      );
      return;
    }

    final details = [
      _strengthController.text,
      _doseController.text,
      _routeController.text,
      _frequencyController.text,
      _durationController.text,
      _quantityController.text,
      _instructionsController.text,
    ].map((value) => value.trim()).where((value) => value.isNotEmpty).toList();

    setState(() {
      _prescriptionItems.add(
        details.isEmpty ? name : '$name • ${details.join(' • ')}',
      );
      _medicationController.clear();
      _strengthController.clear();
      _doseController.clear();
      _routeController.clear();
      _frequencyController.clear();
      _durationController.clear();
      _quantityController.clear();
      _instructionsController.clear();
    });
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        if (compact) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 14),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 14),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _NotSavedBanner extends StatelessWidget {
  const _NotSavedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF9A6700), size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Consultation API is not connected. Information entered here remains only on this screen and will not be saved.',
              style: TextStyle(
                color: Color(0xFF775500),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _HistoryPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _ConsultationSection({
    required this.title,
    required this.description,
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
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
