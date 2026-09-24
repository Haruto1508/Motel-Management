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
public class InvoiceResponse {
    private String id;
    private String invoiceNumber;
    private String roomId;
    private String roomCode;
    private String tenantName;
    private String billingMonth;
    private Double roomAmount;
    private Double electricityAmount;
    private Double waterAmount;
    private Double serviceAmount;
    private Double discountAmount;
    private Double otherAmount;
    private Double totalAmount;
    private Double paidAmount;
    private Double remainingAmount;
    private String status;
    private LocalDateTime dueDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
