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
public class RoomMemberResponse {
    private String id;
    private String roomId;
    private String tenantId;
    private String fullName;
    private String phone;
    private String role;
    private LocalDateTime moveInDate;
}
