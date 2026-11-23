class DoctorProfile {
  final String id;
  final String name;
  final String? contactNumber;
  final String? designation;
  final String? specialization;
  final String clinicId;
  final String clinicName;

  const DoctorProfile({
    required this.id,
    required this.name,
    this.contactNumber,
    this.designation,
    this.specialization,
    required this.clinicId,
    required this.clinicName,
  });
}
