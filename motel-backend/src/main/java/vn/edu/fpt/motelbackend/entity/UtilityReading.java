package vn.edu.fpt.motelbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "utility_readings")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UtilityReading {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Column(name = "billing_month", length = 20)
    private String billingMonth;

    @Column(name = "previous_electricity")
    private Double previousElectricity;

    @Column(name = "current_electricity", nullable = false)
    private Double currentElectricity;

    @Column(name = "previous_water")
    private Double previousWater;

    @Column(name = "current_water", nullable = false)
    private Double currentWater;

    @Column(name = "reading_date")
    private LocalDateTime readingDate;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
