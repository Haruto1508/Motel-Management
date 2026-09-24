package vn.edu.fpt.motelbackend.dto.invoice;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class InvoiceRequest {
    @NotBlank(message = "roomId không được để trống")
    private String roomId;

    @NotBlank(message = "billingMonth không được để trống")
    private String billingMonth;

    @NotNull(message = "roomAmount không được để trống")
    private Double roomAmount;

    private Double electricityAmount = 0.0;
    private Double waterAmount = 0.0;
    private Double serviceAmount = 0.0;
    private Double discountAmount = 0.0;
    private Double otherAmount = 0.0;

    @NotNull(message = "dueDate không được để trống")
    private LocalDateTime dueDate;
}
