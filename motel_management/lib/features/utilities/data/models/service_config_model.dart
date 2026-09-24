import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';

class ServiceConfigModel {
  final String id;
  final String name;
  final String type;
  final double unitPrice;
  final String unitName;
  final bool isActive;

  const ServiceConfigModel({
    required this.id,
    required this.name,
    required this.type,
    required this.unitPrice,
    required this.unitName,
    this.isActive = true,
  });

  factory ServiceConfigModel.fromJson(Map<String, dynamic> json) {
    return ServiceConfigModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'FIXED_ROOM',
      unitPrice: ((json['unitPrice'] ?? json['unit_price'] ?? 0) as num).toDouble(),
      unitName: json['unitName'] as String? ?? json['unit_name'] as String? ?? '',
      isActive: json['isActive'] == 1 || json['isActive'] == true || json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'unitPrice': unitPrice,
      'unitName': unitName,
      'isActive': isActive ? 1 : 0,
    };
  }

  ServiceConfigEntity toEntity() {
    return ServiceConfigEntity(
      id: id,
      name: name,
      type: type,
      unitPrice: unitPrice,
      unitName: unitName,
      isActive: isActive,
    );
  }

  factory ServiceConfigModel.fromEntity(ServiceConfigEntity entity) {
    return ServiceConfigModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      unitPrice: entity.unitPrice,
      unitName: entity.unitName,
      isActive: entity.isActive,
    );
  }
}
