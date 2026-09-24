package vn.edu.fpt.motelbackend.dto.tenant;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TenantResponse {
    private String id;
    private String fullName;
    private String phone;
    private String identityCard;
    private String email;
    private String hometown;
    private String status;
    private String currentRoomId;
    private String currentRoomCode;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
