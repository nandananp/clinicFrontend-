import '../../domain/entities/doctor_profile.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_remote_datasource.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  final DoctorProfileRemoteDataSource dataSource;

  const DoctorProfileRepositoryImpl({required this.dataSource});

  @override
  Future<DoctorProfile> fetchProfile() async {
    final model = await dataSource.fetchProfile();
    return model.toEntity();
  }
}
