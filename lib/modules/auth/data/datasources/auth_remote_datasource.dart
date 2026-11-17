import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/login_response_model.dart';

/// Abstract data source for authentication API calls.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String username, String password);
  Future<void> logout();
}

/// Real API implementation for backend integration.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      return LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map && data['message'] is String)
          ? data['message'] as String
          : 'Unable to connect to server. Please try again.';
      throw Exception(message);
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}