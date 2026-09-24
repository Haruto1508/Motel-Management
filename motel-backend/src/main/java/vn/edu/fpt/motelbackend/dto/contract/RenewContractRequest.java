package vn.edu.fpt.motelbackend.dto.contract;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RenewContractRequest {
    @NotNull(message = "newEndDate không được để trống")
    private LocalDateTime newEndDate;

    private Double newMonthlyRent;
}
