import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel {
  final int totalRooms;
  final int occupiedRooms;
  final int availableRooms;
  final int maintenanceRooms;
  final int totalTenants;
  final int unpaidInvoices;
  final int paidInvoices;
  final double currentMonthRevenue;
  final double currentMonthElectricityKwh;
  final double currentMonthWaterM3;

  const DashboardStatsModel({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.availableRooms,
    required this.maintenanceRooms,
    required this.totalTenants,
    required this.unpaidInvoices,
    required this.paidInvoices,
    required this.currentMonthRevenue,
    required this.currentMonthElectricityKwh,
    required this.currentMonthWaterM3,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalRooms: json['totalRooms'] as int? ?? 0,
      occupiedRooms: json['occupiedRooms'] as int? ?? 0,
      availableRooms: json['availableRooms'] as int? ?? 0,
      maintenanceRooms: json['maintenanceRooms'] as int? ?? 0,
      totalTenants: json['totalTenants'] as int? ?? 0,
      unpaidInvoices: json['unpaidInvoices'] as int? ?? 0,
      paidInvoices: json['paidInvoices'] as int? ?? 0,
      currentMonthRevenue: (json['currentMonthRevenue'] as num?)?.toDouble() ?? 0.0,
      currentMonthElectricityKwh:
          (json['currentMonthElectricityKwh'] as num?)?.toDouble() ?? 0.0,
      currentMonthWaterM3:
          (json['currentMonthWaterM3'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRooms': totalRooms,
      'occupiedRooms': occupiedRooms,
      'availableRooms': availableRooms,
      'maintenanceRooms': maintenanceRooms,
      'totalTenants': totalTenants,
      'unpaidInvoices': unpaidInvoices,
      'paidInvoices': paidInvoices,
      'currentMonthRevenue': currentMonthRevenue,
      'currentMonthElectricityKwh': currentMonthElectricityKwh,
      'currentMonthWaterM3': currentMonthWaterM3,
    };
  }

  DashboardStatsEntity toEntity() {
    return DashboardStatsEntity(
      totalRooms: totalRooms,
      occupiedRooms: occupiedRooms,
      availableRooms: availableRooms,
      maintenanceRooms: maintenanceRooms,
      totalTenants: totalTenants,
      unpaidInvoices: unpaidInvoices,
      paidInvoices: paidInvoices,
      currentMonthRevenue: currentMonthRevenue,
      currentMonthElectricityKwh: currentMonthElectricityKwh,
      currentMonthWaterM3: currentMonthWaterM3,
    );
  }
}
