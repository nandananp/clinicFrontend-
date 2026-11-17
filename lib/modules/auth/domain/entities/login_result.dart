import 'auth_user.dart';

class LoginResult {
  final AuthUser user;
  final String message;
  const LoginResult({required this.user, required this.message});
}