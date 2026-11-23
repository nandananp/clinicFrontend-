class PatientDirectoryEntry {
  final String id;
  final String name;
  final String? patientNumber;
  final String? contactNumber;

  const PatientDirectoryEntry({
    required this.id,
    required this.name,
    this.patientNumber,
    this.contactNumber,
  });

  factory PatientDirectoryEntry.fromJson(Map<String, dynamic> json) {
    final id = _firstString(json, const ['patientId', 'id']);
    final name =
        _firstString(json, const ['fullName', 'name']) ??
        [
          json['firstName']?.toString().trim(),
          json['lastName']?.toString().trim(),
        ].whereType<String>().where((part) => part.isNotEmpty).join(' ');

    if (id == null || name.isEmpty) {
      throw const FormatException(
        'Patient record is missing its identifier or name.',
      );
    }

    return PatientDirectoryEntry(
      id: id,
      name: name,
      patientNumber: _firstString(json, const [
        'patientNumber',
        'patientNo',
        'medicalRecordNumber',
      ]),
      contactNumber: _firstString(json, const [
        'contactNumber',
        'phoneNumber',
        'phone',
      ]),
    );
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}
