/// Centralized route path constants.
/// All navigation paths are defined here for consistency.
class AppPages {
  AppPages._();

  // ─── Auth ─────────────────────────────────────────────────────────
  static const String login = '/login';

  // ─── Dashboard ────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ─── Patients ─────────────────────────────────────────────────────
  static const String patients = '/dashboard/patients';
  static const String patientRegister = '/dashboard/patients/register';
  static const String patientEdit = '/dashboard/patients/edit/:id';
  static const String patientDetails = '/dashboard/patients/:id';

  // ─── Appointments ─────────────────────────────────────────────────
  static const String appointments = '/dashboard/appointments';

  // ─── Consultations ────────────────────────────────────────────────
  static const String consultations = '/dashboard/consultations';
  static const String newConsultation = '/dashboard/consultations/new';

  // ─── Prescriptions ────────────────────────────────────────────────
  static const String prescriptions = '/dashboard/prescriptions';
  static const String newPrescription = '/dashboard/prescriptions/new';

  // ─── Medical Records ──────────────────────────────────────────────
  static const String medicalRecords = '/dashboard/medical-records';

  // ─── Medicines ────────────────────────────────────────────────────
  static const String medicines = '/dashboard/medicines';

  // ─── Profile & Settings ───────────────────────────────────────────
  static const String profile = '/dashboard/profile';
  static const String settings = '/dashboard/settings';
}
