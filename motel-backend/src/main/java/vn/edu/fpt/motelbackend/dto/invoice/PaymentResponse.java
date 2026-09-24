package vn.edu.fpt.motelbackend.dto.invoice;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {
    private String id;
    private String invoiceId;
    private Double amount;
    private String paymentMethod;
    private LocalDateTime paymentDate;
    private String notes;
    private LocalDateTime createdAt;
}
