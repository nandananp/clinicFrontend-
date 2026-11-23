import '../domain/entities/patient_registration.dart';
import '../domain/repositories/patient_repository.dart';

class RegisterPatientInteractor {
  final PatientRepository repository;

  const RegisterPatientInteractor({required this.repository});

  Future<String> execute(PatientRegistration registration) {
    return repository.registerPatient(registration);
  }
}
