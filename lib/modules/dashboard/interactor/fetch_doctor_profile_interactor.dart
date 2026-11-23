import '../domain/entities/doctor_profile.dart';
import '../domain/repositories/doctor_profile_repository.dart';

class FetchDoctorProfileInteractor {
  final DoctorProfileRepository repository;

  const FetchDoctorProfileInteractor({required this.repository});

  Future<DoctorProfile> execute() => repository.fetchProfile();
}
