import '../../domain/entities/doctor_profile.dart';

class DoctorProfileModel {
  final String doctorId;
  final String name;
  final String? contactNumber;
  final String? designation;
  final String? specialization;
  final String clinicId;
  final String clinicName;

  const DoctorProfileModel({
    required this.doctorId,
    required this.name,
    this.contactNumber,
    this.designation,
    this.specialization,
    required this.clinicId,
    required this.clinicName,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      doctorId: _requiredString(json, 'doctorId'),
      name: _requiredString(json, 'name'),
      contactNumber: json['contactNumber']?.toString(),
      designation: json['designation']?.toString(),
      specialization: json['specialization']?.toString(),
      clinicId: _requiredString(json, 'clinicId'),
      clinicName: _requiredString(json, 'clinicName'),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    if (value == null || value.isEmpty) {
      throw FormatException('Doctor profile is missing $key.');
    }
    return value;
  }

  DoctorProfile toEntity() => DoctorProfile(
    id: doctorId,
    name: name,
    contactNumber: contactNumber,
    designation: designation,
    specialization: specialization,
    clinicId: clinicId,
    clinicName: clinicName,
  );
}
