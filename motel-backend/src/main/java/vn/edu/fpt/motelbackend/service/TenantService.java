package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.motelbackend.dto.tenant.TenantRequest;
import vn.edu.fpt.motelbackend.dto.tenant.TenantResponse;
import vn.edu.fpt.motelbackend.entity.RoomMember;
import vn.edu.fpt.motelbackend.entity.Tenant;
import vn.edu.fpt.motelbackend.repository.RoomMemberRepository;
import vn.edu.fpt.motelbackend.repository.TenantRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TenantService {

    private final TenantRepository tenantRepository;
    private final RoomMemberRepository roomMemberRepository;

    public List<TenantResponse> getTenants(String query, String status) {
        String cleanQuery = (query != null && !query.trim().isEmpty()) ? query.trim() : null;
        String cleanStatus = (status != null && !status.trim().isEmpty()) ? status.trim().toUpperCase() : null;

        return tenantRepository.findWithFilters(cleanQuery, cleanStatus)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public TenantResponse getTenantById(String id) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khách thuê với ID: " + id));
        return mapToResponse(tenant);
    }

    @Transactional
    public TenantResponse createTenant(TenantRequest request) {
        Tenant tenant = Tenant.builder()
                .fullName(request.getFullName().trim())
                .phone(request.getPhone().trim())
                .identityCard(request.getIdentityCard())
                .email(request.getEmail())
                .hometown(request.getHometown())
                .status(request.getStatus() != null ? request.getStatus().toUpperCase() : "ACTIVE")
                .build();

        return mapToResponse(tenantRepository.save(tenant));
    }

    @Transactional
    public TenantResponse updateTenant(String id, TenantRequest request) {
        Tenant tenant = tenantRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khách thuê với ID: " + id));

        tenant.setFullName(request.getFullName().trim());
        tenant.setPhone(request.getPhone().trim());
        tenant.setIdentityCard(request.getIdentityCard());
        tenant.setEmail(request.getEmail());
        tenant.setHometown(request.getHometown());
        if (request.getStatus() != null) {
            tenant.setStatus(request.getStatus().toUpperCase());
        }

        return mapToResponse(tenantRepository.save(tenant));
    }

    @Transactional
    public void deleteTenant(String id) {
        if (!tenantRepository.existsById(id)) {
            throw new IllegalArgumentException("Không tìm thấy khách thuê với ID: " + id);
        }
        tenantRepository.deleteById(id);
    }

    private TenantResponse mapToResponse(Tenant tenant) {
        Optional<RoomMember> memberOpt = roomMemberRepository.findFirstByTenantId(tenant.getId());

        String roomId = memberOpt.map(m -> m.getRoom().getId()).orElse(null);
        String roomCode = memberOpt.map(m -> m.getRoom().getRoomCode()).orElse(null);

        return TenantResponse.builder()
                .id(tenant.getId())
                .fullName(tenant.getFullName())
                .phone(tenant.getPhone())
                .identityCard(tenant.getIdentityCard())
                .email(tenant.getEmail())
                .hometown(tenant.getHometown())
                .status(tenant.getStatus())
                .currentRoomId(roomId)
                .currentRoomCode(roomCode)
                .createdAt(tenant.getCreatedAt())
                .updatedAt(tenant.getUpdatedAt())
                .build();
    }
}
