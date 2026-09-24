package vn.edu.fpt.motelbackend.dto.room;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RoomMemberRequest {
    @NotBlank(message = "tenantId không được để trống")
    private String tenantId;

    private String role = "MEMBER";

    private LocalDateTime moveInDate;
}
