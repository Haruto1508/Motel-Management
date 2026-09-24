package vn.edu.fpt.motelbackend.dto.invoice;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PaymentRequest {
    @NotBlank(message = "invoiceId không được để trống")
    private String invoiceId;

    @NotNull(message = "amount không được để trống")
    private Double amount;

    private String paymentMethod = "CASH"; // CASH, BANK_TRANSFER, EWALLET
    private String notes;
    private LocalDateTime paymentDate;
}
