import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';

class CreateRoomParams {
  final String roomCode;
  final String name;
  final int floor;
  final double area;
  final double monthlyRent;
  final int capacity;
  final RoomStatus status;
  final String? description;

  const CreateRoomParams({
    required this.roomCode,
    required this.name,
    required this.floor,
    required this.area,
    required this.monthlyRent,
    required this.capacity,
    this.status = RoomStatus.available,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'roomCode': roomCode,
        'name': name,
        'floor': floor,
        'area': area,
        'monthlyRent': monthlyRent,
        'capacity': capacity,
        'status': status.code,
        'description': description,
      };
}

class UpdateRoomParams {
  final String? name;
  final int? floor;
  final double? area;
  final double? monthlyRent;
  final int? capacity;
  final RoomStatus? status;
  final String? description;

  const UpdateRoomParams({
    this.name,
    this.floor,
    this.area,
    this.monthlyRent,
    this.capacity,
    this.status,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (floor != null) map['floor'] = floor;
    if (area != null) map['area'] = area;
    if (monthlyRent != null) map['monthlyRent'] = monthlyRent;
    if (capacity != null) map['capacity'] = capacity;
    if (status != null) map['status'] = status!.code;
    if (description != null) map['description'] = description;
    return map;
  }
}

/// Domain contract for room operations
abstract class RoomRepository {
  Future<List<RoomEntity>> getRooms({
    String? query,
    RoomStatus? status,
    int? floor,
  });

  Future<RoomDetailEntity> getRoomById(String id);

  Future<RoomEntity> createRoom(CreateRoomParams params);

  Future<RoomEntity> updateRoom(String id, UpdateRoomParams params);

  Future<void> deleteRoom(String id);
}
