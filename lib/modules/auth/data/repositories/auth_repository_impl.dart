import 'dart:convert';

import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
/// Coordinates between the remote data source and local token storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<LoginResult> login(String username, String password) async {
    final response = await _dataSource.login(username, password);

    await _tokenStorage.saveToken(response.token);

    // Backend ippo token, role, message mathrame tharunnullu.
    // Baaki fields backend-il add cheyyumbol ivide map cheyyam.
    final user = AuthUser(
      id: '',
      username: username,
      fullName: username,
      email: '',
      role: response.role,
    );

    await _tokenStorage.saveUserData(jsonEncode({
      'id': user.id,
      'username': user.username,
      'fullName': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'specialization': user.specialization,
      'profileImage': user.profileImage,
      'role': user.role,
      'clinicId': user.clinicId,
      'clinicName': user.clinicName,
    }));

    return LoginResult(user: user, message: response.message);
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      // Always clear local credentials, even if server logout fails
      await _tokenStorage.clearAll();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasToken();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final userData = await _tokenStorage.getUserData();
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData) as Map<String, dynamic>;
      return AuthUser(
        id: json['id'] as String,
        username: json['username'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        specialization: json['specialization'] as String?,
        profileImage: json['profileImage'] as String?,
        role: json['role'] as String,
        clinicId: json['clinicId'] as String?,
        clinicName: json['clinicName'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}