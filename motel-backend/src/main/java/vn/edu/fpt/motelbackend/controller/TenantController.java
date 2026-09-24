package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.tenant.TenantRequest;
import vn.edu.fpt.motelbackend.dto.tenant.TenantResponse;
import vn.edu.fpt.motelbackend.service.TenantService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tenants")
@RequiredArgsConstructor
public class TenantController {

    private final TenantService tenantService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<TenantResponse>>> getTenants(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String status) {
        List<TenantResponse> tenants = tenantService.getTenants(query, status);
        return ResponseEntity.ok(ApiResponse.ok(tenants));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TenantResponse>> getTenantById(@PathVariable String id) {
        TenantResponse tenant = tenantService.getTenantById(id);
        return ResponseEntity.ok(ApiResponse.ok(tenant));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TenantResponse>> createTenant(@Valid @RequestBody TenantRequest request) {
        TenantResponse tenant = tenantService.createTenant(request);
        return ResponseEntity.ok(ApiResponse.ok(tenant, "Thêm khách thuê thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<TenantResponse>> updateTenant(
            @PathVariable String id,
            @Valid @RequestBody TenantRequest request) {
        TenantResponse tenant = tenantService.updateTenant(id, request);
        return ResponseEntity.ok(ApiResponse.ok(tenant, "Cập nhật khách thuê thành công"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTenant(@PathVariable String id) {
        tenantService.deleteTenant(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Xóa khách thuê thành công"));
    }
}
