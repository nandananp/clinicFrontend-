import '../entities/patient_directory_entry.dart';
import '../entities/patient_registration.dart';

abstract interface class PatientRepository {
  Future<String> registerPatient(PatientRegistration registration);
  Future<List<PatientDirectoryEntry>> fetchPatients();
}
