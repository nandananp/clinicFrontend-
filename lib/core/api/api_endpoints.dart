/// Centralized API endpoint definitions.
/// All endpoint paths are relative to the base URL defined in .env.
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Authentication ───────────────────────────────────────────────
  static const String login = '/doctor/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/me';
  static const String myClinics = '/me/clinics';

  // ─── Patients ─────────────────────────────────────────────────────
  static const String registerPatient = '/doctor/register/patient';
  static const String doctorProfile = '/doctor/profile';
  static const String patients = '/patients';
  static String patientById(String id) => '/patients/$id';
  static String patientAllergies(String id) => '/patients/$id/allergies';
  static String patientConditions(String id) => '/patients/$id/conditions';
  static String patientConsultations(String id) =>
      '/patients/$id/consultations';

  // ─── Consultations ────────────────────────────────────────────────
  static const String consultations = '/consultations';
  static String consultationById(String id) => '/consultations/$id';
  static String finalizeConsultation(String id) =>
      '/consultations/$id/finalize';

  // ─── Prescriptions ────────────────────────────────────────────────
  static String prescriptionsForConsultation(String consultationId) =>
      '/consultations/$consultationId/prescriptions';
  static String prescriptionById(String id) => '/prescriptions/$id';
  static String finalizePrescription(String id) =>
      '/prescriptions/$id/finalize';
  static String amendPrescription(String id) => '/prescriptions/$id/amendments';

  // ─── Appointments ─────────────────────────────────────────────────
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';

  // ─── Medicines ────────────────────────────────────────────────────
  static const String medicines = '/medicines';
  static String medicineById(String id) => '/medicines/$id';

  // ─── Queue ────────────────────────────────────────────────────────
  static const String queue = '/queue';
  static String queueEntryStatus(String id) => '/queue/$id/status';
}
