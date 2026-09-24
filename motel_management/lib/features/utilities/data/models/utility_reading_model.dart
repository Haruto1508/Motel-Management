import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';

class UtilityReadingModel {
  final String id;
  final String roomId;
  final String? roomCode;
  final String billingMonth;
  final DateTime readingDate;
  final double? previousElectricity;
  final double currentElectricity;
  final double electricityPrice;
  final double? previousWater;
  final double currentWater;
  final double waterPrice;
  final String waterCalcMethod;
  final int numberOfTenants;
  final String? note;
  final DateTime? createdAt;

  const UtilityReadingModel({
    required this.id,
    required this.roomId,
    this.roomCode,
    required this.billingMonth,
    required this.readingDate,
    this.previousElectricity,
    required this.currentElectricity,
    this.electricityPrice = 3500.0,
    this.previousWater,
    required this.currentWater,
    this.waterPrice = 25000.0,
    this.waterCalcMethod = 'METER',
    this.numberOfTenants = 1,
    this.note,
    this.createdAt,
  });

  factory UtilityReadingModel.fromJson(Map<String, dynamic> json) {
    return UtilityReadingModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String? ?? json['room_id'] as String? ?? '',
      roomCode: json['roomCode'] as String? ?? json['room_code'] as String?,
      billingMonth: json['billingMonth'] as String? ?? json['billing_month'] as String? ?? '',
      readingDate: json['readingDate'] != null
          ? DateTime.tryParse(json['readingDate'].toString()) ?? DateTime.now()
          : (json['reading_date'] != null
              ? DateTime.tryParse(json['reading_date'].toString()) ?? DateTime.now()
              : DateTime.now()),
      previousElectricity: (json['previousElectricity'] ?? json['previous_electricity']) != null
          ? (json['previousElectricity'] ?? json['previous_electricity'] as num).toDouble()
          : null,
      currentElectricity: ((json['currentElectricity'] ?? json['current_electricity'] ?? 0) as num).toDouble(),
      electricityPrice: ((json['electricityPrice'] ?? json['electricity_price'] ?? 3500) as num).toDouble(),
      previousWater: (json['previousWater'] ?? json['previous_water']) != null
          ? (json['previousWater'] ?? json['previous_water'] as num).toDouble()
          : null,
      currentWater: ((json['currentWater'] ?? json['current_water'] ?? 0) as num).toDouble(),
      waterPrice: ((json['waterPrice'] ?? json['water_price'] ?? 25000) as num).toDouble(),
      waterCalcMethod: json['waterCalcMethod'] as String? ?? json['water_calc_method'] as String? ?? 'METER',
      numberOfTenants: (json['numberOfTenants'] ?? json['number_of_tenants'] ?? 1) as int,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'billingMonth': billingMonth,
      'readingDate': readingDate.toIso8601String(),
      'previousElectricity': previousElectricity,
      'currentElectricity': currentElectricity,
      'electricityPrice': electricityPrice,
      'previousWater': previousWater,
      'currentWater': currentWater,
      'waterPrice': waterPrice,
      'waterCalcMethod': waterCalcMethod,
      'numberOfTenants': numberOfTenants,
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UtilityReadingEntity toEntity() {
    return UtilityReadingEntity(
      id: id,
      roomId: roomId,
      roomCode: roomCode,
      billingMonth: billingMonth,
      readingDate: readingDate,
      previousElectricity: previousElectricity,
      currentElectricity: currentElectricity,
      electricityPrice: electricityPrice,
      previousWater: previousWater,
      currentWater: currentWater,
      waterPrice: waterPrice,
      waterCalcMethod: WaterCalcMethod.fromString(waterCalcMethod),
      numberOfTenants: numberOfTenants,
      note: note,
      createdAt: createdAt,
    );
  }

  factory UtilityReadingModel.fromEntity(UtilityReadingEntity entity) {
    return UtilityReadingModel(
      id: entity.id,
      roomId: entity.roomId,
      roomCode: entity.roomCode,
      billingMonth: entity.billingMonth,
      readingDate: entity.readingDate,
      previousElectricity: entity.previousElectricity,
      currentElectricity: entity.currentElectricity,
      electricityPrice: entity.electricityPrice,
      previousWater: entity.previousWater,
      currentWater: entity.currentWater,
      waterPrice: entity.waterPrice,
      waterCalcMethod: entity.waterCalcMethod.code,
      numberOfTenants: entity.numberOfTenants,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
