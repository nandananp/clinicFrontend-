/// Domain entity representing an authenticated user (Doctor).
/// Independent of API response shapes — mapped from DTOs in the data layer.
class AuthUser {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final String? specialization;
  final String? profileImage;
  final String role;
  final String? clinicId;
  final String? clinicName;

  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    this.specialization,
    this.profileImage,
    required this.role,
    this.clinicId,
    this.clinicName,
  });

  /// Creates a copy of this [AuthUser] with the given fields replaced.
  AuthUser copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? specialization,
    String? profileImage,
    String? role,
    String? clinicId,
    String? clinicName,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
    );
  }

  @override
  String toString() => 'AuthUser(id: $id, username: $username, fullName: $fullName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
