import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/patient_remote_datasource.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/entities/patient_directory_entry.dart';
import '../../domain/repositories/patient_repository.dart';

final patientDirectoryDataSourceProvider = Provider<PatientRemoteDataSource>((
  ref,
) {
  return PatientRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final patientDirectoryRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(
    dataSource: ref.watch(patientDirectoryDataSourceProvider),
  );
});

final patientDirectoryPresenterProvider =
    AsyncNotifierProvider<
      PatientDirectoryPresenter,
      List<PatientDirectoryEntry>
    >(PatientDirectoryPresenter.new);

class PatientDirectoryPresenter
    extends AsyncNotifier<List<PatientDirectoryEntry>> {
  late final PatientRepository _repository;

  @override
  Future<List<PatientDirectoryEntry>> build() async {
    _repository = ref.watch(patientDirectoryRepositoryProvider);
    return _repository.fetchPatients();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchPatients);
  }
}
