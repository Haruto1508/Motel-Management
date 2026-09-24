import 'package:equatable/equatable.dart';

/// Pure domain entity containing high-level rental property statistics
class DashboardStatsEntity extends Equatable {
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

  const DashboardStatsEntity({
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

  /// Calculates occupancy rate as percentage (0 - 100)
  double get occupancyRate {
    if (totalRooms == 0) return 0.0;
    return (occupiedRooms / totalRooms) * 100.0;
  }

  @override
  List<Object?> get props => [
        totalRooms,
        occupiedRooms,
        availableRooms,
        maintenanceRooms,
        totalTenants,
        unpaidInvoices,
        paidInvoices,
        currentMonthRevenue,
        currentMonthElectricityKwh,
        currentMonthWaterM3,
      ];
}
