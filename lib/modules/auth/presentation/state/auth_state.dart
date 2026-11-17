import '../../domain/entities/auth_user.dart';

/// Sealed class representing all possible authentication states.
/// Used by the Presenter (AuthNotifier) to communicate view state.
sealed class AuthState {
  const AuthState();
}

/// Initial state — app just launched, auth status unknown.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state — authentication in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state — user is logged in.
class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String? message;
  const AuthAuthenticated({required this.user, this.message});
}

/// Unauthenticated state — user is not logged in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state — authentication failed.
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
}
