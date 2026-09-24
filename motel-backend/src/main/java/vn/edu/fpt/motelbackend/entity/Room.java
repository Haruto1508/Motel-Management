package vn.edu.fpt.motelbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import vn.edu.fpt.motelbackend.enums.RoomStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "rooms")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @Column(name = "room_code", nullable = false, unique = true, length = 50)
    private String roomCode;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    @Builder.Default
    private Integer floor = 1;

    @Column(nullable = false)
    @Builder.Default
    private Double area = 20.0;

    @Column(name = "monthly_rent", nullable = false)
    @Builder.Default
    private Double monthlyRent = 2000000.0;

    @Column(nullable = false)
    @Builder.Default
    private Integer capacity = 2;

    @Column(nullable = false, length = 50)
    @Builder.Default
    @Enumerated(EnumType.STRING)
    private RoomStatus status = RoomStatus.AVAILABLE; // AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "current_occupancy", nullable = false)
    @Builder.Default
    private Integer currentOccupancy = 0;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
