import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_app/modules/dashboard/data/models/doctor_profile_model.dart';

void main() {
  test('maps the doctor profile response to its API model', () {
    final model = DoctorProfileModel.fromJson({
      'doctorId': '00000000-0000-4000-8000-000000000001',
      'name': 'Dr. Example',
      'contactNumber': null,
      'designation': 'MBBS',
      'specialization': 'General practice',
      'clinicId': '00000000-0000-4000-8000-000000000002',
      'clinicName': 'Demo Clinic',
    });

    expect(model.doctorId, '00000000-0000-4000-8000-000000000001');
    expect(model.name, 'Dr. Example');
    expect(model.contactNumber, isNull);
    expect(model.designation, 'MBBS');
    expect(model.specialization, 'General practice');
    expect(model.clinicId, '00000000-0000-4000-8000-000000000002');
    expect(model.clinicName, 'Demo Clinic');

    final entity = model.toEntity();
    expect(entity.name, 'Dr. Example');
    expect(entity.clinicName, 'Demo Clinic');
  });

  test('rejects a profile without the clinic identifier', () {
    expect(
      () => DoctorProfileModel.fromJson({
        'doctorId': '00000000-0000-4000-8000-000000000001',
        'name': 'Dr. Example',
        'clinicName': 'Demo Clinic',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
