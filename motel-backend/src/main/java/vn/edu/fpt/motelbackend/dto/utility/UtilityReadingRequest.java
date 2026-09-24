package vn.edu.fpt.motelbackend.dto.utility;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UtilityReadingRequest {
    @NotBlank(message = "roomId không được để trống")
    private String roomId;

    private String billingMonth;

    private Double previousElectricity;

    @NotNull(message = "currentElectricity không được để trống")
    private Double currentElectricity;

    private Double previousWater;

    @NotNull(message = "currentWater không được để trống")
    private Double currentWater;

    private LocalDateTime readingDate;
}
