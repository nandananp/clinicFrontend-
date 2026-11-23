import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/patient_remote_datasource.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/entities/patient_registration.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../interactor/register_patient_interactor.dart';

final patientRemoteDataSourceProvider = Provider<PatientRemoteDataSource>((
  ref,
) {
  return PatientRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(
    dataSource: ref.watch(patientRemoteDataSourceProvider),
  );
});

final registerPatientInteractorProvider = Provider<RegisterPatientInteractor>((
  ref,
) {
  return RegisterPatientInteractor(
    repository: ref.watch(patientRepositoryProvider),
  );
});

final patientRegistrationPresenterProvider =
    NotifierProvider<PatientRegistrationPresenter, AsyncValue<void>>(
      PatientRegistrationPresenter.new,
    );

class PatientRegistrationPresenter extends Notifier<AsyncValue<void>> {
  late final RegisterPatientInteractor _registerPatient;

  @override
  AsyncValue<void> build() {
    _registerPatient = ref.watch(registerPatientInteractorProvider);
    return const AsyncData(null);
  }

  Future<String> register(PatientRegistration registration) async {
    state = const AsyncLoading();
    try {
      final message = await _registerPatient.execute(registration);
      state = const AsyncData(null);
      return message;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
