import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';
import 'package:rental_management/features/contracts/domain/usecases/create_contract_usecase.dart';
import 'package:rental_management/features/contracts/domain/usecases/get_contracts_usecase.dart';
import 'package:rental_management/features/contracts/domain/usecases/update_contract_usecase.dart';

class MockContractRepository extends Mock implements ContractRepository {}

void main() {
  late MockContractRepository mockRepository;
  late GetContractsUseCase getContractsUseCase;
  late GetContractByIdUseCase getContractByIdUseCase;
  late CreateContractUseCase createContractUseCase;
  late TerminateContractUseCase terminateContractUseCase;

  setUp(() {
    mockRepository = MockContractRepository();
    getContractsUseCase = GetContractsUseCase(mockRepository);
    getContractByIdUseCase = GetContractByIdUseCase(mockRepository);
    createContractUseCase = CreateContractUseCase(mockRepository);
    terminateContractUseCase = TerminateContractUseCase(mockRepository);
  });

  final tActiveContract = ContractEntity(
    id: 'contract-1',
    contractNumber: 'HD-2026-001',
    roomId: 'room-1',
    roomCode: 'P101',
    primaryTenantId: 'tenant-1',
    primaryTenantName: 'Nguyễn Văn A',
    primaryTenantPhone: '0901234567',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 150)),
    monthlyRent: 3500000,
    depositAmount: 3500000,
    paymentDueDay: 5,
    status: ContractStatus.active,
  );

  final tDraftContract = ContractEntity(
    id: 'contract-2',
    contractNumber: 'HD-2026-002',
    roomId: 'room-2',
    roomCode: 'P102',
    primaryTenantId: 'tenant-2',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 180)),
    monthlyRent: 4000000,
    depositAmount: 4000000,
    paymentDueDay: 5,
    status: ContractStatus.draft,
  );

  final tExpiredContract = ContractEntity(
    id: 'contract-3',
    contractNumber: 'HD-2026-003',
    roomId: 'room-3',
    primaryTenantId: 'tenant-3',
    startDate: DateTime.now().subtract(const Duration(days: 365)),
    endDate: DateTime.now().subtract(const Duration(days: 10)),
    monthlyRent: 3000000,
    depositAmount: 3000000,
    paymentDueDay: 5,
    status: ContractStatus.expired,
  );

  group('ContractStatus & ContractEntity Tests', () {
    test('ContractStatus.fromString should parse status code correctly', () {
      expect(ContractStatus.fromString('ACTIVE'), equals(ContractStatus.active));
      expect(ContractStatus.fromString('EXPIRED'), equals(ContractStatus.expired));
      expect(ContractStatus.fromString('TERMINATED'), equals(ContractStatus.terminated));
      expect(ContractStatus.fromString('DRAFT'), equals(ContractStatus.draft));
      expect(ContractStatus.fromString('CANCELLED'), equals(ContractStatus.cancelled));
      expect(ContractStatus.fromString('unknown_status'), equals(ContractStatus.active));
    });

    test('ContractEntity computed properties should work correctly', () {
      expect(tActiveContract.isActive, isTrue);
      expect(tActiveContract.isExpired, isFalse);
      expect(tActiveContract.remainingDays, greaterThan(0));

      expect(tDraftContract.isActive, isFalse);

      expect(tExpiredContract.isActive, isFalse);
      expect(tExpiredContract.isExpired, isTrue);
      expect(tExpiredContract.remainingDays, equals(0));
    });
  });

  group('Contract UseCases Tests', () {
    test('GetContractsUseCase should return list of contracts from repository', () async {
      when(() => mockRepository.getContracts(
            query: any(named: 'query'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => [tActiveContract, tDraftContract]);

      final result = await getContractsUseCase.call();

      expect(result.length, equals(2));
      expect(result.first.contractNumber, equals('HD-2026-001'));
      verify(() => mockRepository.getContracts()).called(1);
    });

    test('GetContractByIdUseCase should return contract detail', () async {
      when(() => mockRepository.getContractById('contract-1'))
          .thenAnswer((_) async => tActiveContract);

      final result = await getContractByIdUseCase.call('contract-1');

      expect(result.id, equals('contract-1'));
      verify(() => mockRepository.getContractById('contract-1')).called(1);
    });

    test('CreateContractUseCase should validate dates and call repository createContract', () async {
      when(() => mockRepository.createContract(any()))
          .thenAnswer((_) async => tActiveContract);

      final params = CreateContractParams(
        roomId: 'room-1',
        primaryTenantId: 'tenant-1',
        contractNumber: 'HD-2026-001',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
        monthlyRent: 3500000,
        depositAmount: 3500000,
      );

      final result = await createContractUseCase.call(params);

      expect(result.id, equals('contract-1'));
      verify(() => mockRepository.createContract(any())).called(1);
    });

    test('CreateContractUseCase should throw ArgumentError when end date is before start date', () async {
      final invalidParams = CreateContractParams(
        roomId: 'room-1',
        primaryTenantId: 'tenant-1',
        contractNumber: 'HD-2026-001',
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 1, 1),
        monthlyRent: 3500000,
        depositAmount: 3500000,
      );

      expect(() => createContractUseCase.call(invalidParams), throwsArgumentError);
    });

    test('TerminateContractUseCase should call repository terminateContract', () async {
      when(() => mockRepository.terminateContract(
            'contract-1',
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => {});

      await terminateContractUseCase.call(
        'contract-1',
        reason: 'Hết hạn và dọn đi',
      );

      verify(() => mockRepository.terminateContract(
            'contract-1',
            reason: 'Hết hạn và dọn đi',
          )).called(1);
    });
  });
}
