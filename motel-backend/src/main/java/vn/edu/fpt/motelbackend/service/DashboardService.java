package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.edu.fpt.motelbackend.dto.dashboard.DashboardStatsResponse;
import vn.edu.fpt.motelbackend.repository.InvoiceRepository;
import vn.edu.fpt.motelbackend.repository.RoomRepository;
import vn.edu.fpt.motelbackend.repository.TenantRepository;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import vn.edu.fpt.motelbackend.enums.RoomStatus;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final RoomRepository roomRepository;
    private final TenantRepository tenantRepository;
    private final InvoiceRepository invoiceRepository;

    public DashboardStatsResponse getStats(String billingMonth) {
        String month = (billingMonth != null && !billingMonth.trim().isEmpty())
                ? billingMonth.trim()
                : LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM/yyyy"));

        int totalRooms = (int) roomRepository.count();
        int occupiedRooms = (int) roomRepository.countByStatus(RoomStatus.OCCUPIED);
        int availableRooms = (int) roomRepository.countByStatus(RoomStatus.AVAILABLE);
        int maintenanceRooms = (int) roomRepository.countByStatus(RoomStatus.MAINTENANCE);

        double occupancyRate = totalRooms > 0 ? ((double) occupiedRooms / totalRooms) * 100.0 : 0.0;
        int totalTenants = (int) tenantRepository.countByStatus("ACTIVE");

        Double totalRev = invoiceRepository.sumTotalAmountByBillingMonth(month);
        Double collectedRev = invoiceRepository.sumPaidAmountByBillingMonth(month);

        double totalRevenue = totalRev != null ? totalRev : 0.0;
        double collectedRevenue = collectedRev != null ? collectedRev : 0.0;
        double pendingRevenue = Math.max(0.0, totalRevenue - collectedRevenue);

        return DashboardStatsResponse.builder()
                .totalRooms(totalRooms)
                .occupiedRooms(occupiedRooms)
                .availableRooms(availableRooms)
                .maintenanceRooms(maintenanceRooms)
                .occupancyRate(Math.round(occupancyRate * 10.0) / 10.0)
                .totalTenants(totalTenants)
                .totalRevenue(totalRevenue)
                .collectedRevenue(collectedRevenue)
                .pendingRevenue(pendingRevenue)
                .billingMonth(month)
                .build();
    }
}
