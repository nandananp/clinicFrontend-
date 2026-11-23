import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/doctor_profile_model.dart';

abstract interface class DoctorProfileRemoteDataSource {
  Future<DoctorProfileModel> fetchProfile();
}

class DoctorProfileRemoteDataSourceImpl
    implements DoctorProfileRemoteDataSource {
  final ApiClient apiClient;

  const DoctorProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DoctorProfileModel> fetchProfile() async {
    final response = await apiClient.get(ApiEndpoints.doctorProfile);
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Invalid doctor profile response.');
    }
    return DoctorProfileModel.fromJson(body);
  }
}
