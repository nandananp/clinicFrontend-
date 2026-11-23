import '../entities/doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<DoctorProfile> fetchProfile();
}
