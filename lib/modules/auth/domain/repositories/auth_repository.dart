import '../entities/auth_user.dart';
import '../entities/login_result.dart';

/// Abstract repository interface for authentication.
/// Defines the contract between the domain and data layers.
/// Implementation resides in the data layer.
abstract class AuthRepository {
  /// Authenticates user with username and password.
  /// Returns [LoginResult] (user + backend message) on success, throws on failure.
  Future<LoginResult> login(String username, String password);

  /// Logs out the current user and clears stored credentials.
  Future<void> logout();

  /// Checks if the user has a valid authentication token.
  Future<bool> isAuthenticated();

  /// Retrieves the currently authenticated user from storage.
  /// Returns null if no user data is available.
  Future<AuthUser?> getCurrentUser();
}