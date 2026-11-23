import '../../domain/entities/patient_directory_entry.dart';
import '../../domain/entities/patient_registration.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource dataSource;

  const PatientRepositoryImpl({required this.dataSource});

  @override
  Future<String> registerPatient(PatientRegistration registration) {
    return dataSource.registerPatient(registration);
  }

  @override
  Future<List<PatientDirectoryEntry>> fetchPatients() {
    return dataSource.fetchPatients();
  }
}
