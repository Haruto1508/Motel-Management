package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.motelbackend.dto.contract.ContractRequest;
import vn.edu.fpt.motelbackend.dto.contract.ContractResponse;
import vn.edu.fpt.motelbackend.dto.contract.RenewContractRequest;
import vn.edu.fpt.motelbackend.dto.contract.TerminateContractRequest;
import vn.edu.fpt.motelbackend.entity.Contract;
import vn.edu.fpt.motelbackend.entity.Room;
import vn.edu.fpt.motelbackend.entity.Tenant;
import vn.edu.fpt.motelbackend.repository.ContractRepository;
import vn.edu.fpt.motelbackend.repository.RoomRepository;
import vn.edu.fpt.motelbackend.repository.TenantRepository;

import java.time.Year;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ContractService {

    private final ContractRepository contractRepository;
    private final RoomRepository roomRepository;
    private final TenantRepository tenantRepository;

    public List<ContractResponse> getContracts(String query, String status) {
        String cleanQuery = (query != null && !query.trim().isEmpty()) ? query.trim() : null;
        String cleanStatus = (status != null && !status.trim().isEmpty()) ? status.trim().toUpperCase() : null;

        return contractRepository.findWithFilters(cleanQuery, cleanStatus)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public ContractResponse getContractById(String id) {
        Contract contract = contractRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hợp đồng với ID: " + id));
        return mapToResponse(contract);
    }

    @Transactional
    public ContractResponse createContract(ContractRequest request) {
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + request.getRoomId()));

        Tenant tenant = tenantRepository.findById(request.getPrimaryTenantId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy khách thuê với ID: " + request.getPrimaryTenantId()));

        String contractNumber = request.getContractNumber();
        if (contractNumber == null || contractNumber.trim().isEmpty()) {
            contractNumber = "HD-" + Year.now().getValue() + "-" + room.getRoomCode() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        }

        Contract contract = Contract.builder()
                .contractNumber(contractNumber)
                .room(room)
                .primaryTenant(tenant)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .depositAmount(request.getDepositAmount() != null ? request.getDepositAmount() : 0.0)
                .monthlyRent(request.getMonthlyRent())
                .status("ACTIVE")
                .build();

        return mapToResponse(contractRepository.save(contract));
    }

    @Transactional
    public ContractResponse updateContract(String id, ContractRequest request) {
        Contract contract = contractRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hợp đồng với ID: " + id));

        if (request.getStartDate() != null) contract.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) contract.setEndDate(request.getEndDate());
        if (request.getDepositAmount() != null) contract.setDepositAmount(request.getDepositAmount());
        if (request.getMonthlyRent() != null) contract.setMonthlyRent(request.getMonthlyRent());

        return mapToResponse(contractRepository.save(contract));
    }

    @Transactional
    public void terminateContract(String id, TerminateContractRequest request) {
        Contract contract = contractRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hợp đồng với ID: " + id));

        contract.setStatus("TERMINATED");
        contractRepository.save(contract);
    }

    @Transactional
    public ContractResponse renewContract(String id, RenewContractRequest request) {
        Contract contract = contractRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hợp đồng với ID: " + id));

        contract.setEndDate(request.getNewEndDate());
        if (request.getNewMonthlyRent() != null) {
            contract.setMonthlyRent(request.getNewMonthlyRent());
        }
        contract.setStatus("ACTIVE");

        return mapToResponse(contractRepository.save(contract));
    }

    private ContractResponse mapToResponse(Contract contract) {
        return ContractResponse.builder()
                .id(contract.getId())
                .contractNumber(contract.getContractNumber())
                .roomId(contract.getRoom().getId())
                .roomCode(contract.getRoom().getRoomCode())
                .primaryTenantId(contract.getPrimaryTenant().getId())
                .primaryTenantName(contract.getPrimaryTenant().getFullName())
                .startDate(contract.getStartDate())
                .endDate(contract.getEndDate())
                .depositAmount(contract.getDepositAmount())
                .monthlyRent(contract.getMonthlyRent())
                .status(contract.getStatus())
                .createdAt(contract.getCreatedAt())
                .updatedAt(contract.getUpdatedAt())
                .build();
    }
}
