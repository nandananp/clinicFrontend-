class LoginResponseModel {
  final String message;
  final String token;
  final String role;

  const LoginResponseModel({
    required this.message,
    required this.token,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] as String? ?? 'Login successful',
      token: json['token'] as String,
      role: json['role'] as String? ?? 'DOCTOR',
    );
  }
}