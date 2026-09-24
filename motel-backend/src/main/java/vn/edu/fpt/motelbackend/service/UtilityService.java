package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.motelbackend.dto.utility.ServiceConfigRequest;
import vn.edu.fpt.motelbackend.dto.utility.ServiceConfigResponse;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingRequest;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingResponse;
import vn.edu.fpt.motelbackend.entity.Room;
import vn.edu.fpt.motelbackend.entity.ServiceConfig;
import vn.edu.fpt.motelbackend.entity.UtilityReading;
import vn.edu.fpt.motelbackend.repository.RoomRepository;
import vn.edu.fpt.motelbackend.repository.ServiceConfigRepository;
import vn.edu.fpt.motelbackend.repository.UtilityReadingRepository;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UtilityService {

    private final UtilityReadingRepository utilityReadingRepository;
    private final ServiceConfigRepository serviceConfigRepository;
    private final RoomRepository roomRepository;

    public List<UtilityReadingResponse> getReadings(String roomId, String billingMonth) {
        String cleanRoomId = (roomId != null && !roomId.trim().isEmpty()) ? roomId.trim() : null;
        String cleanMonth = (billingMonth != null && !billingMonth.trim().isEmpty()) ? billingMonth.trim() : null;

        return utilityReadingRepository.findWithFilters(cleanRoomId, cleanMonth)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public UtilityReadingResponse getLatestReading(String roomId) {
        return utilityReadingRepository.findFirstByRoomIdOrderByReadingDateDesc(roomId)
                .map(this::mapToResponse)
                .orElse(null);
    }

    @Transactional
    public UtilityReadingResponse recordReading(UtilityReadingRequest request) {
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + request.getRoomId()));

        String billingMonth = request.getBillingMonth();
        if (billingMonth == null || billingMonth.trim().isEmpty()) {
            billingMonth = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM/yyyy"));
        }

        UtilityReading reading = UtilityReading.builder()
                .room(room)
                .billingMonth(billingMonth)
                .previousElectricity(request.getPreviousElectricity())
                .currentElectricity(request.getCurrentElectricity())
                .previousWater(request.getPreviousWater())
                .currentWater(request.getCurrentWater())
                .readingDate(request.getReadingDate() != null ? request.getReadingDate() : LocalDateTime.now())
                .build();

        return mapToResponse(utilityReadingRepository.save(reading));
    }

    @Transactional
    public UtilityReadingResponse updateReading(String id, UtilityReadingRequest request) {
        UtilityReading reading = utilityReadingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bản ghi chỉ số với ID: " + id));

        if (request.getCurrentElectricity() != null) reading.setCurrentElectricity(request.getCurrentElectricity());
        if (request.getPreviousElectricity() != null) reading.setPreviousElectricity(request.getPreviousElectricity());
        if (request.getCurrentWater() != null) reading.setCurrentWater(request.getCurrentWater());
        if (request.getPreviousWater() != null) reading.setPreviousWater(request.getPreviousWater());
        if (request.getBillingMonth() != null) reading.setBillingMonth(request.getBillingMonth());
        if (request.getReadingDate() != null) reading.setReadingDate(request.getReadingDate());

        return mapToResponse(utilityReadingRepository.save(reading));
    }

    @Transactional
    public void deleteReading(String id) {
        if (!utilityReadingRepository.existsById(id)) {
            throw new IllegalArgumentException("Không tìm thấy bản ghi chỉ số với ID: " + id);
        }
        utilityReadingRepository.deleteById(id);
    }

    public List<ServiceConfigResponse> getServices() {
        return serviceConfigRepository.findAll()
                .stream()
                .map(this::mapServiceToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ServiceConfigResponse updateService(String id, ServiceConfigRequest request) {
        ServiceConfig config = serviceConfigRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy dịch vụ với ID: " + id));

        if (request.getUnitPrice() != null) config.setUnitPrice(request.getUnitPrice());
        if (request.getServiceName() != null) config.setServiceName(request.getServiceName());
        if (request.getUnit() != null) config.setUnit(request.getUnit());
        if (request.getCalcMethod() != null) config.setCalcMethod(request.getCalcMethod());

        return mapServiceToResponse(serviceConfigRepository.save(config));
    }

    private UtilityReadingResponse mapToResponse(UtilityReading u) {
        double elecDiff = (u.getCurrentElectricity() != null && u.getPreviousElectricity() != null)
                ? Math.max(0, u.getCurrentElectricity() - u.getPreviousElectricity()) : 0.0;
        double waterDiff = (u.getCurrentWater() != null && u.getPreviousWater() != null)
                ? Math.max(0, u.getCurrentWater() - u.getPreviousWater()) : 0.0;

        return UtilityReadingResponse.builder()
                .id(u.getId())
                .roomId(u.getRoom().getId())
                .roomCode(u.getRoom().getRoomCode())
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
    }

    private ServiceConfigResponse mapServiceToResponse(ServiceConfig s) {
        return ServiceConfigResponse.builder()
                .id(s.getId())
                .serviceName(s.getServiceName())
                .unitPrice(s.getUnitPrice())
                .unit(s.getUnit())
                .calcMethod(s.getCalcMethod())
                .createdAt(s.getCreatedAt())
                .updatedAt(s.getUpdatedAt())
                .build();
    }
}
