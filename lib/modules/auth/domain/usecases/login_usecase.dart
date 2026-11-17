import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

/// Use case (Interactor) for user login.
/// Encapsulates the business logic for authentication.
/// Part of the VIPER Interactor layer.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase({required AuthRepository repository})
      : _repository = repository;

  /// Executes the login use case.
  /// Validates inputs and delegates to the repository.
  /// Returns [LoginResult] (user + backend message) on success.
  Future<LoginResult> execute(String username, String password) async {
    // Basic validation at the use case level
    if (username.trim().isEmpty) {
      throw Exception('Username is required');
    }
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }

    return await _repository.login(username.trim(), password);
  }
}