import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';
import 'package:rental_management/features/utilities/domain/usecases/get_utility_readings_usecase.dart';
import 'package:rental_management/features/utilities/domain/usecases/record_utility_reading_usecase.dart';
import 'package:rental_management/features/utilities/domain/usecases/service_config_usecases.dart';

class MockUtilityRepository extends Mock implements UtilityRepository {}

void main() {
  late MockUtilityRepository mockRepository;
  late GetUtilityReadingsUseCase getReadingsUseCase;
  late GetLatestReadingUseCase getLatestReadingUseCase;
  late RecordUtilityReadingUseCase recordReadingUseCase;
  late GetServiceConfigsUseCase getServicesUseCase;

  setUp(() {
    mockRepository = MockUtilityRepository();
    getReadingsUseCase = GetUtilityReadingsUseCase(mockRepository);
    getLatestReadingUseCase = GetLatestReadingUseCase(mockRepository);
    recordReadingUseCase = RecordUtilityReadingUseCase(mockRepository);
    getServicesUseCase = GetServiceConfigsUseCase(mockRepository);
  });

  final tReadingMeter = UtilityReadingEntity(
    id: 'rd-1',
    roomId: 'room-1',
    roomCode: 'P101',
    billingMonth: '09/2026',
    readingDate: DateTime(2026, 9, 20),
    previousElectricity: 100,
    currentElectricity: 150,
    electricityPrice: 3500,
    previousWater: 20,
    currentWater: 25,
    waterPrice: 25000,
    waterCalcMethod: WaterCalcMethod.meter,
  );

  final tReadingFixedWater = UtilityReadingEntity(
    id: 'rd-2',
    roomId: 'room-2',
    roomCode: 'P102',
    billingMonth: '09/2026',
    readingDate: DateTime(2026, 9, 20),
    previousElectricity: 200,
    currentElectricity: 280,
    electricityPrice: 3500,
    previousWater: 10,
    currentWater: 10,
    waterPrice: 100000,
    waterCalcMethod: WaterCalcMethod.fixed,
  );

  final tReadingPerPersonWater = UtilityReadingEntity(
    id: 'rd-3',
    roomId: 'room-3',
    roomCode: 'P103',
    billingMonth: '09/2026',
    readingDate: DateTime(2026, 9, 20),
    previousElectricity: 300,
    currentElectricity: 400,
    electricityPrice: 3500,
    waterPrice: 50000,
    waterCalcMethod: WaterCalcMethod.perPerson,
    numberOfTenants: 3,
    currentWater: 0,
  );

  group('UtilityReadingEntity Calculations', () {
    test('Calculates electricity consumption and amount accurately', () {
      expect(tReadingMeter.electricityConsumption, equals(50.0));
      expect(tReadingMeter.electricityAmount, equals(175000.0)); // 50 * 3500
    });

    test('Calculates meter-based water consumption and amount accurately', () {
      expect(tReadingMeter.waterConsumption, equals(5.0));
      expect(tReadingMeter.waterAmount, equals(125000.0)); // 5 * 25000
      expect(tReadingMeter.totalAmount, equals(300000.0)); // 175000 + 125000
    });

    test('Calculates fixed-fee water amount accurately', () {
      expect(tReadingFixedWater.waterConsumption, equals(0.0));
      expect(tReadingFixedWater.waterAmount, equals(100000.0));
      expect(tReadingFixedWater.electricityConsumption, equals(80.0));
      expect(tReadingFixedWater.electricityAmount, equals(280000.0)); // 80 * 3500
      expect(tReadingFixedWater.totalAmount, equals(380000.0));
    });

    test('Calculates per-person water amount accurately based on tenant count', () {
      expect(tReadingPerPersonWater.waterAmount, equals(150000.0)); // 50000 * 3
      expect(tReadingPerPersonWater.electricityConsumption, equals(100.0));
      expect(tReadingPerPersonWater.electricityAmount, equals(350000.0)); // 100 * 3500
      expect(tReadingPerPersonWater.totalAmount, equals(500000.0));
    });

    test('WaterCalcMethod.fromString parses correctly', () {
      expect(WaterCalcMethod.fromString('METER'), equals(WaterCalcMethod.meter));
      expect(WaterCalcMethod.fromString('FIXED'), equals(WaterCalcMethod.fixed));
      expect(WaterCalcMethod.fromString('PER_PERSON'), equals(WaterCalcMethod.perPerson));
      expect(WaterCalcMethod.fromString('unknown'), equals(WaterCalcMethod.meter));
    });
  });

  group('RecordUtilityReadingUseCase Tests', () {
    test('Throws ArgumentError if current electricity reading is less than previous', () async {
      final invalidParams = RecordUtilityParams(
        roomId: 'room-1',
        billingMonth: '09/2026',
        readingDate: DateTime.now(),
        previousElectricity: 200,
        currentElectricity: 150, // invalid: < previous
        currentWater: 30,
      );

      expect(() => recordReadingUseCase.call(invalidParams), throwsArgumentError);
    });

    test('Throws ArgumentError if current water reading is less than previous in meter mode', () async {
      final invalidParams = RecordUtilityParams(
        roomId: 'room-1',
        billingMonth: '09/2026',
        readingDate: DateTime.now(),
        previousElectricity: 100,
        currentElectricity: 150,
        previousWater: 50,
        currentWater: 40, // invalid: < previous
        waterCalcMethod: WaterCalcMethod.meter,
      );

      expect(() => recordReadingUseCase.call(invalidParams), throwsArgumentError);
    });

    test('Delegates to repository and returns reading entity on valid params', () async {
      when(() => mockRepository.recordReading(any()))
          .thenAnswer((_) async => tReadingMeter);

      final validParams = RecordUtilityParams(
        roomId: 'room-1',
        billingMonth: '09/2026',
        readingDate: DateTime(2026, 9, 20),
        previousElectricity: 100,
        currentElectricity: 150,
        previousWater: 20,
        currentWater: 25,
      );

      final result = await recordReadingUseCase.call(validParams);

      expect(result.id, equals('rd-1'));
      expect(result.electricityConsumption, equals(50));
      verify(() => mockRepository.recordReading(any())).called(1);
    });
  });

  group('GetUtilityReadings & GetServices UseCase Tests', () {
    test('GetUtilityReadingsUseCase returns list from repository', () async {
      when(() => mockRepository.getReadings(
            roomId: any(named: 'roomId'),
            billingMonth: any(named: 'billingMonth'),
          )).thenAnswer((_) async => [tReadingMeter, tReadingFixedWater]);

      final result = await getReadingsUseCase.call();

      expect(result.length, equals(2));
      verify(() => mockRepository.getReadings()).called(1);
    });

    test('GetLatestReadingUseCase returns latest reading for a room', () async {
      when(() => mockRepository.getLatestReading('room-1'))
          .thenAnswer((_) async => tReadingMeter);

      final result = await getLatestReadingUseCase.call('room-1');

      expect(result?.id, equals('rd-1'));
      verify(() => mockRepository.getLatestReading('room-1')).called(1);
    });

    test('GetServiceConfigsUseCase returns services list from repository', () async {
      const services = [
        ServiceConfigEntity(id: '1', name: 'Điện', type: 'METER', unitPrice: 3500, unitName: 'kWh'),
        ServiceConfigEntity(id: '2', name: 'Internet', type: 'FIXED_ROOM', unitPrice: 100000, unitName: 'phòng/tháng'),
      ];

      when(() => mockRepository.getServices()).thenAnswer((_) async => services);

      final result = await getServicesUseCase.call();

      expect(result.length, equals(2));
      expect(result.first.name, equals('Điện'));
      verify(() => mockRepository.getServices()).called(1);
    });
  });
}
