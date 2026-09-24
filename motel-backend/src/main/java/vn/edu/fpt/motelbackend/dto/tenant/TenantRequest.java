package vn.edu.fpt.motelbackend.dto.tenant;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TenantRequest {
    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;

    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;

    private String identityCard;
    private String email;
    private String hometown;
    private String status = "ACTIVE";
}
