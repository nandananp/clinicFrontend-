/// User roles within the clinic system.
enum UserRole {
  doctor('DOCTOR', 'Doctor'),
  receptionist('RECEPTIONIST', 'Receptionist'),
  pharmacist('PHARMACIST', 'Pharmacist'),
  admin('ADMIN', 'Administrator');

  final String value;
  final String label;
  const UserRole(this.value, this.label);
}

/// Authentication status.
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

/// Generic loading status for async operations.
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
  empty,
}

/// Appointment status.
enum AppointmentStatus {
  scheduled('SCHEDULED', 'Scheduled'),
  confirmed('CONFIRMED', 'Confirmed'),
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled'),
  noShow('NO_SHOW', 'No Show');

  final String value;
  final String label;
  const AppointmentStatus(this.value, this.label);
}

/// Consultation status.
enum ConsultationStatus {
  draft('DRAFT', 'Draft'),
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled');

  final String value;
  final String label;
  const ConsultationStatus(this.value, this.label);
}

/// Prescription status.
enum PrescriptionStatus {
  draft('DRAFT', 'Draft'),
  finalized('FINALIZED', 'Finalized'),
  amended('AMENDED', 'Amended'),
  cancelled('CANCELLED', 'Cancelled');

  final String value;
  final String label;
  const PrescriptionStatus(this.value, this.label);
}

/// Patient gender.
enum Gender {
  male('MALE', 'Male'),
  female('FEMALE', 'Female'),
  other('OTHER', 'Other');

  final String value;
  final String label;
  const Gender(this.value, this.label);
}

/// Blood group types.
enum BloodGroup {
  aPositive('A_POSITIVE', 'A+'),
  aNegative('A_NEGATIVE', 'A-'),
  bPositive('B_POSITIVE', 'B+'),
  bNegative('B_NEGATIVE', 'B-'),
  abPositive('AB_POSITIVE', 'AB+'),
  abNegative('AB_NEGATIVE', 'AB-'),
  oPositive('O_POSITIVE', 'O+'),
  oNegative('O_NEGATIVE', 'O-');

  final String value;
  final String label;
  const BloodGroup(this.value, this.label);
}
