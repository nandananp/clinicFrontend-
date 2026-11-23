import 'package:clinic_app/modules/dashboard/domain/entities/doctor_profile.dart';
import 'package:clinic_app/modules/dashboard/domain/repositories/doctor_profile_repository.dart';
import 'package:clinic_app/modules/dashboard/presentation/presenter/dashboard_presenter.dart';
import 'package:clinic_app/modules/dashboard/presentation/view/dashboard_screen.dart';
import 'package:clinic_app/modules/patients/domain/entities/patient_directory_entry.dart';
import 'package:clinic_app/modules/patients/domain/repositories/patient_repository.dart';
import 'package:clinic_app/modules/patients/domain/entities/patient_registration.dart';
import 'package:clinic_app/modules/patients/presentation/presenter/patient_directory_presenter.dart';
import 'package:clinic_app/modules/patients/presentation/view/patient_directory_screen.dart';
import 'package:clinic_app/modules/patients/presentation/view/patient_registration_screen.dart';
import 'package:clinic_app/modules/patients/presentation/presenter/patient_registration_presenter.dart';
import 'package:clinic_app/modules/auth/domain/entities/auth_user.dart';
import 'package:clinic_app/modules/auth/presentation/providers/auth_provider.dart';
import 'package:clinic_app/modules/auth/presentation/state/auth_state.dart';
import 'package:clinic_app/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('loads doctor details in a menu anchored to the profile icon', (
    tester,
  ) async {
    final repository = _FakeDoctorProfileRepository();
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          doctorProfileRepositoryProvider.overrideWithValue(repository),
          authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 0);
    expect(find.text('New patient'), findsNothing);
    expect(find.text('New consultation'), findsNothing);
    expect(find.text('Consultations'), findsNothing);
    expect(find.text('Prescriptions'), findsNothing);
    expect(find.text('Medical records'), findsNothing);
    expect(find.text('Doctor profile'), findsNothing);
    expect(find.text('Billing'), findsAtLeastNWidgets(2));
    expect(
      tester.getCenter(find.text('Billing').first).dy,
      greaterThan(tester.getCenter(find.text('Medicines').first).dy),
    );
    expect(find.text('Register Patient'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Today at your clinic'), findsOneWidget);

    await tester.tap(find.byTooltip('Doctor profile'));
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 1);
    expect(find.text('Dr. Demo'), findsOneWidget);
    expect(find.text('Demo Clinic'), findsAtLeastNWidgets(2));
    expect(find.text('General practice'), findsOneWidget);
    expect(find.text('Doctor details'), findsNothing);
    AppToast.clearAll();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets(
    'patient registration loads clinic details and enables creation',
    (tester) async {
      final repository = _FakeDoctorProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorProfileRepositoryProvider.overrideWithValue(repository),
            patientRegistrationPresenterProvider.overrideWith(
              _FakePatientRegistrationPresenter.new,
            ),
          ],
          child: const MaterialApp(home: PatientRegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.fetchCount, 1);
      expect(find.text('Demo Clinic'), findsOneWidget);
      final createButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Create patient'),
      );
      expect(createButton.onPressed, isNotNull);
    },
  );

  testWidgets('selecting a patient opens that patient consultation', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/dashboard/patients',
      routes: [
        GoRoute(
          path: '/dashboard/patients',
          builder: (context, state) => const PatientDirectoryScreen(
            patients: [
              PatientDirectoryEntry(
                id: 'patient-123',
                name: 'Sample Patient',
                patientNumber: 'P-100',
                contactNumber: '9000000000',
              ),
            ],
          ),
        ),
        GoRoute(
          path: '/dashboard/patients/:id/consultation',
          builder: (context, state) =>
              Text('Consultation for ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sample Patient'));
    await tester.pumpAndSettle();

    expect(find.text('Consultation for patient-123'), findsOneWidget);
  });

  testWidgets('patient directory shows records and keeps registration at top', (
    tester,
  ) async {
    final repository = _FakePatientRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientDirectoryRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: PatientDirectoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nandana NP'), findsOneWidget);
    expect(find.text('Patient No. P-100  •  8590116078'), findsOneWidget);
    expect(find.text('Register patient'), findsOneWidget);
    expect(find.text('Register a patient'), findsNothing);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(
    user: const AuthUser(
      id: 'doctor-id',
      username: 'doctor',
      fullName: 'Dr. Demo',
      email: '',
      role: 'DOCTOR',
      clinicName: 'Demo Clinic',
    ),
  );
}

class _FakeDoctorProfileRepository implements DoctorProfileRepository {
  var fetchCount = 0;

  @override
  Future<DoctorProfile> fetchProfile() async {
    fetchCount++;
    return const DoctorProfile(
      id: 'doctor-id',
      name: 'Dr. Demo',
      designation: 'MBBS',
      specialization: 'General practice',
      clinicId: 'clinic-id',
      clinicName: 'Demo Clinic',
    );
  }
}

class _FakePatientRegistrationPresenter extends PatientRegistrationPresenter {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<String> register(PatientRegistration registration) async => 'Saved';
}

class _FakePatientRepository implements PatientRepository {
  @override
  Future<String> registerPatient(PatientRegistration registration) async =>
      'Saved';

  @override
  Future<List<PatientDirectoryEntry>> fetchPatients() async => const [
    PatientDirectoryEntry(
      id: 'patient-100',
      name: 'Nandana NP',
      patientNumber: 'P-100',
      contactNumber: '8590116078',
    ),
  ];
}
