package vn.edu.fpt.motelbackend.dto.contract;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ContractRequest {
    private String contractNumber;

    @NotBlank(message = "roomId không được để trống")
    private String roomId;

    @NotBlank(message = "primaryTenantId không được để trống")
    private String primaryTenantId;

    @NotNull(message = "startDate không được để trống")
    private LocalDateTime startDate;

    @NotNull(message = "endDate không được để trống")
    private LocalDateTime endDate;

    private Double depositAmount = 0.0;

    @NotNull(message = "monthlyRent không được để trống")
    private Double monthlyRent;
}
