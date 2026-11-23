import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/doctor_profile_remote_datasource.dart';
import '../../data/repositories/doctor_profile_repository_impl.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../../interactor/fetch_doctor_profile_interactor.dart';

final doctorProfileDataSourceProvider = Provider<DoctorProfileRemoteDataSource>(
  (ref) {
    return DoctorProfileRemoteDataSourceImpl(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

final doctorProfileRepositoryProvider = Provider<DoctorProfileRepository>((
  ref,
) {
  return DoctorProfileRepositoryImpl(
    dataSource: ref.watch(doctorProfileDataSourceProvider),
  );
});

final fetchDoctorProfileInteractorProvider =
    Provider<FetchDoctorProfileInteractor>((ref) {
      return FetchDoctorProfileInteractor(
        repository: ref.watch(doctorProfileRepositoryProvider),
      );
    });

final doctorProfilePresenterProvider =
    NotifierProvider<DoctorProfilePresenter, AsyncValue<DoctorProfile?>>(
      DoctorProfilePresenter.new,
    );

class DoctorProfilePresenter extends Notifier<AsyncValue<DoctorProfile?>> {
  late final FetchDoctorProfileInteractor _fetchProfile;

  @override
  AsyncValue<DoctorProfile?> build() {
    _fetchProfile = ref.watch(fetchDoctorProfileInteractorProvider);
    return const AsyncData(null);
  }

  Future<DoctorProfile> loadProfile() async {
    state = const AsyncLoading();
    try {
      final profile = await _fetchProfile.execute();
      state = AsyncData(profile);
      return profile;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
