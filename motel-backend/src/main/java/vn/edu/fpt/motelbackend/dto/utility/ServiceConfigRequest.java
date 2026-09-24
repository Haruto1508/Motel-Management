package vn.edu.fpt.motelbackend.dto.utility;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ServiceConfigRequest {
    private String serviceName;

    @NotNull(message = "unitPrice không được để trống")
    private Double unitPrice;

    private String unit;
    private String calcMethod;
}
