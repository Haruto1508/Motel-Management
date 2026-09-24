package vn.edu.fpt.motelbackend.dto.utility;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UtilityReadingResponse {
    private String id;
    private String roomId;
    private String roomCode;
    private String billingMonth;
    private Double previousElectricity;
    private Double currentElectricity;
    private Double electricityConsumption;
    private Double previousWater;
    private Double currentWater;
    private Double waterConsumption;
    private LocalDateTime readingDate;
    private LocalDateTime createdAt;
}
