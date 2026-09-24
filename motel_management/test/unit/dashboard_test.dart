import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:rental_management/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rental_management/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;
  late GetDashboardStatsUseCase useCase;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardStatsUseCase(mockRepository);
  });

  const tStats = DashboardStatsEntity(
    totalRooms: 10,
    occupiedRooms: 8,
    availableRooms: 2,
    maintenanceRooms: 0,
    totalTenants: 15,
    unpaidInvoices: 3,
    paidInvoices: 5,
    currentMonthRevenue: 25000000.0,
    currentMonthElectricityKwh: 350.0,
    currentMonthWaterM3: 45.0,
  );

  test('occupancyRate should compute correct percentage', () {
    expect(tStats.occupancyRate, equals(80.0));
  });

  test('GetDashboardStatsUseCase should delegate to DashboardRepository', () async {
    when(() => mockRepository.getStats(billingMonth: any(named: 'billingMonth')))
        .thenAnswer((_) async => tStats);

    final result = await useCase(billingMonth: '2026-09');

    expect(result, equals(tStats));
    verify(() => mockRepository.getStats(billingMonth: '2026-09')).called(1);
  });
}
