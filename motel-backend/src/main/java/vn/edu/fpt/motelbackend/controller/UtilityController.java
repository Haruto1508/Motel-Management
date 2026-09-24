package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.utility.ServiceConfigRequest;
import vn.edu.fpt.motelbackend.dto.utility.ServiceConfigResponse;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingRequest;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingResponse;
import vn.edu.fpt.motelbackend.service.UtilityService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/utilities")
@RequiredArgsConstructor
public class UtilityController {

    private final UtilityService utilityService;

    @GetMapping("/readings")
    public ResponseEntity<ApiResponse<List<UtilityReadingResponse>>> getReadings(
            @RequestParam(required = false) String roomId,
            @RequestParam(required = false) String billingMonth) {
        List<UtilityReadingResponse> readings = utilityService.getReadings(roomId, billingMonth);
        return ResponseEntity.ok(ApiResponse.ok(readings));
    }

    @GetMapping("/readings/latest")
    public ResponseEntity<ApiResponse<UtilityReadingResponse>> getLatestReading(
            @RequestParam String roomId) {
        UtilityReadingResponse reading = utilityService.getLatestReading(roomId);
        return ResponseEntity.ok(ApiResponse.ok(reading));
    }

    @PostMapping("/readings")
    public ResponseEntity<ApiResponse<UtilityReadingResponse>> recordReading(
            @Valid @RequestBody UtilityReadingRequest request) {
        UtilityReadingResponse reading = utilityService.recordReading(request);
        return ResponseEntity.ok(ApiResponse.ok(reading, "Ghi chỉ số điện nước thành công"));
    }

    @PutMapping("/readings/{id}")
    public ResponseEntity<ApiResponse<UtilityReadingResponse>> updateReading(
            @PathVariable String id,
            @Valid @RequestBody UtilityReadingRequest request) {
        UtilityReadingResponse reading = utilityService.updateReading(id, request);
        return ResponseEntity.ok(ApiResponse.ok(reading, "Cập nhật chỉ số thành công"));
    }

    @DeleteMapping("/readings/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteReading(@PathVariable String id) {
        utilityService.deleteReading(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Xóa chỉ số thành công"));
    }

    @GetMapping("/services")
    public ResponseEntity<ApiResponse<List<ServiceConfigResponse>>> getServices() {
        List<ServiceConfigResponse> services = utilityService.getServices();
        return ResponseEntity.ok(ApiResponse.ok(services));
    }

    @PutMapping("/services/{id}")
    public ResponseEntity<ApiResponse<ServiceConfigResponse>> updateService(
            @PathVariable String id,
            @RequestBody ServiceConfigRequest request) {
        ServiceConfigResponse service = utilityService.updateService(id, request);
        return ResponseEntity.ok(ApiResponse.ok(service, "Cập nhật bảng giá dịch vụ thành công"));
    }
}
