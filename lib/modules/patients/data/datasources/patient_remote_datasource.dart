import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/patient_directory_entry.dart';
import '../../domain/entities/patient_registration.dart';

abstract interface class PatientRemoteDataSource {
  Future<String> registerPatient(PatientRegistration registration);
  Future<List<PatientDirectoryEntry>> fetchPatients();
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient apiClient;

  const PatientRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> registerPatient(PatientRegistration registration) async {
    final response = await apiClient.post(
      ApiEndpoints.registerPatient,
      data: {
        'clinicId': registration.clinicId,
        'firstName': registration.firstName,
        'lastName': registration.lastName,
        'dob': _dateOnly(registration.dateOfBirth),
        'gender': registration.gender,
        'contactNumber': registration.contactNumber,
        'email': registration.email,
        'address': registration.address,
        'bloodGroup': registration.bloodGroup,
        'emergencyContactName': registration.emergencyContactName,
        'emergencyContactNumber': registration.emergencyContactNumber,
      },
    );

    final body = response.data;
    if (body is String && body.trim().isNotEmpty) return body;
    if (body is Map<String, dynamic> && body['message'] != null) {
      return body['message'].toString();
    }
    return 'Patient created successfully';
  }

  @override
  Future<List<PatientDirectoryEntry>> fetchPatients() async {
    final response = await apiClient.get(ApiEndpoints.patients);
    final records = _patientRecords(response.data);
    return records.map(PatientDirectoryEntry.fromJson).toList(growable: false);
  }

  List<Map<String, dynamic>> _patientRecords(dynamic body) {
    if (body is List) {
      return body.map(_patientRecord).toList(growable: false);
    }

    if (body is Map<String, dynamic>) {
      for (final key in const ['patients', 'data', 'content', 'items']) {
        final value = body[key];
        if (value is List) {
          return value.map(_patientRecord).toList(growable: false);
        }
        if (value is Map<String, dynamic>) {
          for (final nestedKey in const ['patients', 'items', 'content']) {
            final nestedValue = value[nestedKey];
            if (nestedValue is List) {
              return nestedValue.map(_patientRecord).toList(growable: false);
            }
          }
        }
      }
    }

    throw const FormatException('Invalid patient list response.');
  }

  Map<String, dynamic> _patientRecord(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Invalid patient record in patient list.');
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
