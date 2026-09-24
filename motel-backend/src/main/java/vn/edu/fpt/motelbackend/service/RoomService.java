package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.motelbackend.dto.contract.ContractResponse;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceResponse;
import vn.edu.fpt.motelbackend.dto.room.*;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingResponse;
import vn.edu.fpt.motelbackend.entity.*;
import vn.edu.fpt.motelbackend.enums.RoomStatus;
import vn.edu.fpt.motelbackend.repository.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final RoomRepository roomRepository;
    private final RoomMemberRepository roomMemberRepository;
    private final TenantRepository tenantRepository;
    private final ContractRepository contractRepository;
    private final UtilityReadingRepository utilityReadingRepository;
    private final InvoiceRepository invoiceRepository;

    public List<RoomResponse> getRooms(String query, String status, Integer floor) {
        String cleanQuery = (query != null && !query.trim().isEmpty()) ? query.trim() : null;
        String cleanStatus = (status != null && !status.trim().isEmpty()) ? status.trim().toUpperCase() : null;

        return roomRepository.findWithFilters(cleanQuery, cleanStatus, floor)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public RoomDetailResponse getRoomDetail(String id) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + id));

        // Members
        List<RoomMemberResponse> memberResponses = roomMemberRepository.findByRoomId(id)
                .stream()
                .map(m -> RoomMemberResponse.builder()
                        .id(m.getId())
                        .roomId(room.getId())
                        .tenantId(m.getTenant().getId())
                        .fullName(m.getTenant().getFullName())
                        .phone(m.getTenant().getPhone())
                        .role(m.getRole())
                        .moveInDate(m.getMoveInDate())
                        .build())
                .collect(Collectors.toList());

        // Active Contract
        ContractResponse activeContract = contractRepository.findFirstByRoomIdAndStatus(id, "ACTIVE")
                .map(c -> ContractResponse.builder()
                        .id(c.getId())
                        .contractNumber(c.getContractNumber())
                        .roomId(room.getId())
                        .roomCode(room.getRoomCode())
                        .primaryTenantId(c.getPrimaryTenant().getId())
                        .primaryTenantName(c.getPrimaryTenant().getFullName())
                        .startDate(c.getStartDate())
                        .endDate(c.getEndDate())
                        .depositAmount(c.getDepositAmount())
                        .monthlyRent(c.getMonthlyRent())
                        .status(c.getStatus())
                        .createdAt(c.getCreatedAt())
                        .updatedAt(c.getUpdatedAt())
                        .build())
                .orElse(null);

        // Latest Utilities
        UtilityReadingResponse latestUtilities = utilityReadingRepository.findFirstByRoomIdOrderByReadingDateDesc(id)
                .map(u -> {
                    double elecDiff = (u.getCurrentElectricity() != null && u.getPreviousElectricity() != null)
                            ? Math.max(0, u.getCurrentElectricity() - u.getPreviousElectricity()) : 0.0;
                    double waterDiff = (u.getCurrentWater() != null && u.getPreviousWater() != null)
                            ? Math.max(0, u.getCurrentWater() - u.getPreviousWater()) : 0.0;
                    return UtilityReadingResponse.builder()
                            .id(u.getId())
                            .roomId(room.getId())
                            .roomCode(room.getRoomCode())
                            .billingMonth(u.getBillingMonth())
                            .previousElectricity(u.getPreviousElectricity())
                            .currentElectricity(u.getCurrentElectricity())
                            .electricityConsumption(elecDiff)
                            .previousWater(u.getPreviousWater())
                            .currentWater(u.getCurrentWater())
                            .waterConsumption(waterDiff)
                            .readingDate(u.getReadingDate())
                            .createdAt(u.getCreatedAt())
                            .build();
                })
                .orElse(null);

        // Current Invoice
        InvoiceResponse currentInvoice = invoiceRepository.findFirstByRoomIdOrderByDueDateDesc(id)
                .map(i -> {
                    double remaining = Math.max(0, i.getTotalAmount() - (i.getPaidAmount() != null ? i.getPaidAmount() : 0.0));
                    return InvoiceResponse.builder()
                            .id(i.getId())
                            .invoiceNumber(i.getInvoiceNumber())
                            .roomId(room.getId())
                            .roomCode(room.getRoomCode())
                            .tenantName(i.getTenantName())
                            .billingMonth(i.getBillingMonth())
                            .roomAmount(i.getRoomAmount())
                            .electricityAmount(i.getElectricityAmount())
                            .waterAmount(i.getWaterAmount())
                            .serviceAmount(i.getServiceAmount())
                            .discountAmount(i.getDiscountAmount())
                            .otherAmount(i.getOtherAmount())
                            .totalAmount(i.getTotalAmount())
                            .paidAmount(i.getPaidAmount())
                            .remainingAmount(remaining)
                            .status(i.getStatus())
                            .dueDate(i.getDueDate())
                            .createdAt(i.getCreatedAt())
                            .updatedAt(i.getUpdatedAt())
                            .build();
                })
                .orElse(null);

        return RoomDetailResponse.builder()
                .room(mapToResponse(room))
                .members(memberResponses)
                .activeContract(activeContract)
                .latestUtilities(latestUtilities)
                .currentInvoice(currentInvoice)
                .build();
    }

    @Transactional
    public RoomResponse createRoom(RoomRequest request) {
        if (roomRepository.findByRoomCode(request.getRoomCode().trim()).isPresent()) {
            throw new IllegalArgumentException("Mã phòng " + request.getRoomCode() + " đã tồn tại");
        }

        Room room = Room.builder()
                .roomCode(request.getRoomCode().trim())
                .name(request.getName().trim())
                .floor(request.getFloor() != null ? request.getFloor() : 1)
                .area(request.getArea() != null ? request.getArea() : 20.0)
                .monthlyRent(request.getMonthlyRent())
                .capacity(request.getCapacity() != null ? request.getCapacity() : 2)
                .status(request.getStatus() != null ? RoomStatus.toRoomStatus(request.getStatus()) : RoomStatus.AVAILABLE)
                .description(request.getDescription())
                .currentOccupancy(0)
                .build();

        return mapToResponse(roomRepository.save(room));
    }

    @Transactional
    public RoomResponse updateRoom(String id, RoomRequest request) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + id));

        room.setRoomCode(request.getRoomCode().trim());
        room.setName(request.getName().trim());
        if (request.getFloor() != null) room.setFloor(request.getFloor());
        if (request.getArea() != null) room.setArea(request.getArea());
        if (request.getMonthlyRent() != null) room.setMonthlyRent(request.getMonthlyRent());
        if (request.getCapacity() != null) room.setCapacity(request.getCapacity());
        if (request.getStatus() != null) room.setStatus(RoomStatus.toRoomStatus(request.getStatus().toUpperCase()));
        room.setDescription(request.getDescription());

        return mapToResponse(roomRepository.save(room));
    }

    @Transactional
    public void deleteRoom(String id) {
        if (!roomRepository.existsById(id)) {
            throw new IllegalArgumentException("Không tìm thấy phòng với ID: " + id);
        }
        roomRepository.deleteById(id);
    }

    @Transactional
    public RoomMemberResponse addMemberToRoom(String roomId, RoomMemberRequest request) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + roomId));

        Tenant tenant = tenantRepository.findById(request.getTenantId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khách thuê với ID: " + request.getTenantId()));

        RoomMember member = RoomMember.builder()
                .room(room)
                .tenant(tenant)
                .role(request.getRole() != null ? request.getRole() : "MEMBER")
                .moveInDate(request.getMoveInDate() != null ? request.getMoveInDate() : LocalDateTime.now())
                .build();

        RoomMember saved = roomMemberRepository.save(member);

        // Update occupancy
        int currentCount = (int) roomMemberRepository.countByRoomId(roomId);
        room.setCurrentOccupancy(currentCount);
        if (currentCount > 0 && room.getStatus() == RoomStatus.AVAILABLE) {
            room.setStatus(RoomStatus.OCCUPIED);
        }
        roomRepository.save(room);

        return RoomMemberResponse.builder()
                .id(saved.getId())
                .roomId(room.getId())
                .tenantId(tenant.getId())
                .fullName(tenant.getFullName())
                .phone(tenant.getPhone())
                .role(saved.getRole())
                .moveInDate(saved.getMoveInDate())
                .build();
    }

    @Transactional
    public void removeMemberFromRoom(String roomId, String memberId) {
        roomMemberRepository.deleteByRoomIdAndId(roomId, memberId);

        Room room = roomRepository.findById(roomId).orElse(null);
        if (room != null) {
            int currentCount = (int) roomMemberRepository.countByRoomId(roomId);
            room.setCurrentOccupancy(currentCount);
            if (currentCount == 0 && "OCCUPIED".equals(room.getStatus())) {
                room.setStatus(RoomStatus.AVAILABLE);
            }
            roomRepository.save(room);
        }
    }

    public RoomResponse mapToResponse(Room room) {
        return RoomResponse.builder()
                .id(room.getId())
                .roomCode(room.getRoomCode())
                .name(room.getName())
                .floor(room.getFloor())
                .area(room.getArea())
                .monthlyRent(room.getMonthlyRent())
                .capacity(room.getCapacity())
                .status(room.getStatus().toString())
                .description(room.getDescription())
                .currentOccupancy(room.getCurrentOccupancy())
                .createdAt(room.getCreatedAt())
                .updatedAt(room.getUpdatedAt())
                .build();
    }
}
