package vn.edu.fpt.motelbackend.dto.room;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RoomRequest {
    @NotBlank(message = "Mã phòng không được để trống")
    private String roomCode;

    @NotBlank(message = "Tên phòng không được để trống")
    private String name;

    private Integer floor = 1;

    private Double area = 20.0;

    @NotNull(message = "Giá thuê phòng không được để trống")
    private Double monthlyRent;

    private Integer capacity = 2;

    private String status = "AVAILABLE";

    private String description;
}
