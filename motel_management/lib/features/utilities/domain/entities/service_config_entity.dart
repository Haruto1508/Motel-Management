import 'package:equatable/equatable.dart';

class ServiceConfigEntity extends Equatable {
  final String id;
  final String name; // e.g. "Điện", "Nước", "Internet WiFi", "Rác sinh hoạt"
  final String type; // FIXED_ROOM, PER_PERSON, METER
  final double unitPrice;
  final String unitName; // "kWh", "m³", "phòng/tháng", "người/tháng"
  final bool isActive;

  const ServiceConfigEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.unitPrice,
    required this.unitName,
    this.isActive = true,
  });

  ServiceConfigEntity copyWith({
    String? id,
    String? name,
    String? type,
    double? unitPrice,
    String? unitName,
    bool? isActive,
  }) {
    return ServiceConfigEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      unitPrice: unitPrice ?? this.unitPrice,
      unitName: unitName ?? this.unitName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, type, unitPrice, unitName, isActive];
}
