import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rental_management/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:rental_management/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rental_management/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

final Provider<DashboardRemoteDataSource> dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSourceImpl(apiClient);
});

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  final preferences = ref.watch(preferencesServiceProvider);

  return DashboardRepositoryImpl(
    remoteDataSource: remoteDataSource,
    preferences: preferences,
  );
});

final Provider<GetDashboardStatsUseCase> getDashboardStatsUseCaseProvider =
    Provider<GetDashboardStatsUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetDashboardStatsUseCase(repository);
});

final FutureProvider<DashboardStatsEntity> dashboardStatsProvider =
    FutureProvider<DashboardStatsEntity>((ref) async {
  final useCase = ref.watch(getDashboardStatsUseCaseProvider);
  return await useCase();
});
