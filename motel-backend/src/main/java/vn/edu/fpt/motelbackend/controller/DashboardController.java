package vn.edu.fpt.motelbackend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.dashboard.DashboardStatsResponse;
import vn.edu.fpt.motelbackend.service.DashboardService;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<DashboardStatsResponse>> getStats(
            @RequestParam(required = false) String billingMonth) {
        DashboardStatsResponse stats = dashboardService.getStats(billingMonth);
        return ResponseEntity.ok(ApiResponse.ok(stats));
    }
}
