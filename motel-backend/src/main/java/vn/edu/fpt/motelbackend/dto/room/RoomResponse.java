package vn.edu.fpt.motelbackend.dto.room;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomResponse {
    private String id;
    private String roomCode;
    private String name;
    private Integer floor;
    private Double area;
    private Double monthlyRent;
    private Integer capacity;
    private String status;
    private String description;
    private Integer currentOccupancy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
