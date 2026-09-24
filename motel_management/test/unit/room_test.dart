import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';
import 'package:rental_management/features/rooms/domain/usecases/create_room_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/get_rooms_usecase.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late MockRoomRepository mockRepository;
  late GetRoomsUseCase getRoomsUseCase;
  late CreateRoomUseCase createRoomUseCase;

  setUp(() {
    mockRepository = MockRoomRepository();
    getRoomsUseCase = GetRoomsUseCase(mockRepository);
    createRoomUseCase = CreateRoomUseCase(mockRepository);
  });

  const tRoom1 = RoomEntity(
    id: 'room-1',
    roomCode: 'P101',
    name: 'Phòng 101',
    floor: 1,
    area: 25.0,
    monthlyRent: 3500000.0,
    capacity: 2,
    currentOccupancy: 2,
    status: RoomStatus.occupied,
  );

  const tRoom2 = RoomEntity(
    id: 'room-2',
    roomCode: 'P102',
    name: 'Phòng 102',
    floor: 1,
    area: 30.0,
    monthlyRent: 4000000.0,
    capacity: 3,
    currentOccupancy: 1,
    status: RoomStatus.available,
  );

  group('RoomEntity Business Logic', () {
    test('isFull should be true when currentOccupancy reaches capacity', () {
      expect(tRoom1.isFull, isTrue);
      expect(tRoom1.availableSlots, equals(0));
    });

    test('availableSlots should calculate remaining capacity', () {
      expect(tRoom2.isFull, isFalse);
      expect(tRoom2.availableSlots, equals(2));
    });
  });

  group('Room UseCases', () {
    test('GetRoomsUseCase should return list of rooms from repository', () async {
      when(() => mockRepository.getRooms(query: any(named: 'query'), status: any(named: 'status'), floor: any(named: 'floor')))
          .thenAnswer((_) async => [tRoom1, tRoom2]);

      final result = await getRoomsUseCase();

      expect(result.length, equals(2));
      expect(result.first.roomCode, equals('P101'));
      verify(() => mockRepository.getRooms()).called(1);
    });

    test('CreateRoomUseCase should delegate params to repository', () async {
      const params = CreateRoomParams(
        roomCode: 'P201',
        name: 'Phòng 201',
        floor: 2,
        area: 28.0,
        monthlyRent: 3800000.0,
        capacity: 2,
      );

      when(() => mockRepository.createRoom(params)).thenAnswer((_) async => tRoom1);

      final result = await createRoomUseCase(params);

      expect(result, equals(tRoom1));
      verify(() => mockRepository.createRoom(params)).called(1);
    });
  });
}
