package vn.edu.fpt.motelbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "invoices")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @Column(name = "invoice_number", nullable = false, unique = true, length = 100)
    private String invoiceNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Column(name = "billing_month", nullable = false, length = 20)
    private String billingMonth; // e.g. "09/2026"

    @Column(name = "tenant_name")
    private String tenantName;

    @Column(name = "room_amount", nullable = false)
    @Builder.Default
    private Double roomAmount = 0.0;

    @Column(name = "electricity_amount")
    @Builder.Default
    private Double electricityAmount = 0.0;

    @Column(name = "water_amount")
    @Builder.Default
    private Double waterAmount = 0.0;

    @Column(name = "service_amount")
    @Builder.Default
    private Double serviceAmount = 0.0;

    @Column(name = "discount_amount")
    @Builder.Default
    private Double discountAmount = 0.0;

    @Column(name = "other_amount")
    @Builder.Default
    private Double otherAmount = 0.0;

    @Column(name = "total_amount", nullable = false)
    @Builder.Default
    private Double totalAmount = 0.0;

    @Column(name = "paid_amount")
    @Builder.Default
    private Double paidAmount = 0.0;

    @Column(length = 50)
    @Builder.Default
    private String status = "UNPAID"; // PAID, UNPAID, PARTIAL, OVERDUE, CANCELLED

    @Column(name = "due_date", nullable = false)
    private LocalDateTime dueDate;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
