import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../state/auth_state.dart';
import '../../../../core/error/api_exception.dart';
// ─── Dependency Providers ─────────────────────────────────────────────

/// Provides the secure token storage instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provides the centralized API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  return ApiClient(tokenStorage: tokenStorage);
});

/// Provides the actual authentication remote data source.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

/// Provides the auth repository implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Provides the login use case (Interactor).
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.watch(authRepositoryProvider));
});

// ─── Presenter (Notifier) ─────────────────────────────────────────────

/// Auth Presenter — manages authentication state.
/// Follows VIPER pattern: View observes this, Interactor handles logic.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final LoginUseCase _loginUseCase;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _loginUseCase = ref.watch(loginUseCaseProvider);

    return const AuthInitial();
  }

  /// Checks if user has an existing valid session.
  Future<void> checkAuthStatus() async {
    try {
      final isAuthenticated = await _repository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _repository.getCurrentUser();

        if (user != null) {
          state = AuthAuthenticated(user: user);
        } else {
          state = const AuthUnauthenticated();
        }
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Authenticates user with credentials.
  ///
  /// Returns the final state ([AuthAuthenticated] or [AuthError]) so the
  /// View can show a toast right after the request finishes.
  Future<AuthState> login(String username, String password) async {
  state = const AuthLoading();

  try {
    final result = await _loginUseCase.execute(
      username,
      password,
    );

    state = AuthAuthenticated(
      user: result.user,
      message: result.message,
    );
  } catch (e) {
    final message = e is ApiException
        ? e.message
        : e.toString().replaceAll('Exception: ', '');

    state = AuthError(message: message);
  }

  return state;
}
  /// Logs out the current user.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }
}

// ─── Auth State Provider ──────────────────────────────────────────────

/// Provides the auth state notifier.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
