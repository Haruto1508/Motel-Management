import 'package:equatable/equatable.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';

/// Pure domain entity representing a rental room
class RoomEntity extends Equatable {
  final String id;
  final String roomCode;
  final String name;
  final int floor;
  final double area;
  final double monthlyRent;
  final int capacity;
  final RoomStatus status;
  final String? description;
  final int currentOccupancy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoomEntity({
    required this.id,
    required this.roomCode,
    required this.name,
    required this.floor,
    required this.area,
    required this.monthlyRent,
    required this.capacity,
    required this.status,
    this.description,
    this.currentOccupancy = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if room has reached its maximum capacity
  bool get isFull => currentOccupancy >= capacity;

  /// Remaining available slots for new members
  int get availableSlots => capacity - currentOccupancy > 0 ? capacity - currentOccupancy : 0;

  RoomEntity copyWith({
    String? id,
    String? roomCode,
    String? name,
    int? floor,
    double? area,
    double? monthlyRent,
    int? capacity,
    RoomStatus? status,
    String? description,
    int? currentOccupancy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      name: name ?? this.name,
      floor: floor ?? this.floor,
      area: area ?? this.area,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      description: description ?? this.description,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomCode,
        name,
        floor,
        area,
        monthlyRent,
        capacity,
        status,
        description,
        currentOccupancy,
        createdAt,
        updatedAt,
      ];
}
