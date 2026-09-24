package vn.edu.fpt.motelbackend.dto.contract;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractResponse {
    private String id;
    private String contractNumber;
    private String roomId;
    private String roomCode;
    private String primaryTenantId;
    private String primaryTenantName;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Double depositAmount;
    private Double monthlyRent;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
