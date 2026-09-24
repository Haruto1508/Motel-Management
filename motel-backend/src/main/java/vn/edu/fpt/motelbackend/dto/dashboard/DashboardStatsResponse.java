package vn.edu.fpt.motelbackend.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsResponse {
    private int totalRooms;
    private int occupiedRooms;
    private int availableRooms;
    private int maintenanceRooms;
    private double occupancyRate;
    private int totalTenants;
    private double totalRevenue;
    private double collectedRevenue;
    private double pendingRevenue;
    private String billingMonth;
}
