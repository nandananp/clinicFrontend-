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
  static const String patientConsultation =
      '/dashboard/patients/:id/consultation';
  static String consultationForPatient(String id) =>
      '/dashboard/patients/$id/consultation';

  // ─── Appointments ─────────────────────────────────────────────────
  static const String appointments = '/dashboard/appointments';

  // ─── Medicines ────────────────────────────────────────────────────
  static const String medicines = '/dashboard/medicines';

  // ─── Billing & Settings ───────────────────────────────────────────
  static const String billing = '/dashboard/billing';
  static const String settings = '/dashboard/settings';
}
