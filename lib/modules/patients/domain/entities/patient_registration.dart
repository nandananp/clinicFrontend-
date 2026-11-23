class PatientRegistration {
  final String clinicId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String contactNumber;
  final String? email;
  final String? address;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactNumber;

  const PatientRegistration({
    required this.clinicId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    this.email,
    this.address,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });
}
