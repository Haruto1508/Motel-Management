package vn.edu.fpt.motelbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "service_configs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ServiceConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @Column(name = "service_name", nullable = false, length = 100)
    private String serviceName;

    @Column(name = "unit_price", nullable = false)
    private Double unitPrice;

    @Column(length = 50)
    private String unit;

    @Column(name = "calc_method", length = 50)
    @Builder.Default
    private String calcMethod = "PER_ROOM"; // METER, PER_ROOM, PER_PERSON

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
