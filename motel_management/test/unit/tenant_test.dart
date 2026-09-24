import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/tenants/domain/entities/room_member_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';
import 'package:rental_management/features/tenants/domain/usecases/create_tenant_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/get_tenants_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/room_member_usecases.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

void main() {
  late MockTenantRepository mockRepository;
  late GetTenantsUseCase getTenantsUseCase;
  late CreateTenantUseCase createTenantUseCase;
  late AddMemberToRoomUseCase addMemberToRoomUseCase;

  setUp(() {
    mockRepository = MockTenantRepository();
    getTenantsUseCase = GetTenantsUseCase(mockRepository);
    createTenantUseCase = CreateTenantUseCase(mockRepository);
    addMemberToRoomUseCase = AddMemberToRoomUseCase(mockRepository);
  });

  const tTenant1 = TenantEntity(
    id: 'tenant-1',
    fullName: 'Trần Thị Thu Hà',
    phone: '0912345678',
    identityNumber: '001298001234',
    status: TenantStatus.active,
    currentRoomId: 'room-1',
    currentRoomCode: 'P101',
  );

  const tTenant2 = TenantEntity(
    id: 'tenant-2',
    fullName: 'Lê Hoàng Nam',
    phone: '0987654321',
    status: TenantStatus.left,
  );

  group('TenantEntity & TenantStatus Tests', () {
    test('isStaying should be true when status is active and currentRoomId is not null', () {
      expect(tTenant1.isStaying, isTrue);
      expect(tTenant2.isStaying, isFalse);
    });

    test('TenantStatus.fromString should parse status code correctly', () {
      expect(TenantStatus.fromString('ACTIVE'), equals(TenantStatus.active));
      expect(TenantStatus.fromString('INACTIVE'), equals(TenantStatus.inactive));
      expect(TenantStatus.fromString('LEFT'), equals(TenantStatus.left));
      expect(TenantStatus.fromString('unknown'), equals(TenantStatus.active));
    });
  });

  group('Tenant UseCases Tests', () {
    test('GetTenantsUseCase should return list of tenants from repository', () async {
      when(() => mockRepository.getTenants(
            query: any(named: 'query'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => [tTenant1, tTenant2]);

      final result = await getTenantsUseCase(query: 'Hà');

      expect(result, equals([tTenant1, tTenant2]));
      verify(() => mockRepository.getTenants(query: 'Hà', status: null)).called(1);
    });

    test('CreateTenantUseCase should call repository.createTenant with params', () async {
      const params = CreateTenantParams(
        fullName: 'Nguyễn Văn Mới',
        phone: '0909090909',
        identityNumber: '012345678901',
      );

      when(() => mockRepository.createTenant(any())).thenAnswer((_) async => tTenant1);

      final result = await createTenantUseCase(params);

      expect(result, equals(tTenant1));
      verify(() => mockRepository.createTenant(params.toJson())).called(1);
    });

    test('AddMemberToRoomUseCase should delegate to repository', () async {
      final tMember = RoomMemberEntity(
        id: 'mem-1',
        roomId: 'room-1',
        tenantId: 'tenant-1',
        fullName: 'Trần Thị Thu Hà',
        phone: '0912345678',
        role: 'PRIMARY',
        moveInDate: DateTime.now(),
        isPrimaryTenant: true,
      );

      when(() => mockRepository.addMemberToRoom(
            roomId: any(named: 'roomId'),
            tenantId: any(named: 'tenantId'),
            role: any(named: 'role'),
            moveInDate: any(named: 'moveInDate'),
          )).thenAnswer((_) async => tMember);

      final result = await addMemberToRoomUseCase(AddMemberToRoomParams(
        roomId: 'room-1',
        tenantId: 'tenant-1',
        role: 'PRIMARY',
        moveInDate: DateTime.now(),
      ));

      expect(result, equals(tMember));
      expect(result.role, equals('PRIMARY'));
    });
  });
}
