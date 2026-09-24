package vn.edu.fpt.motelbackend.dto.utility;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ServiceConfigResponse {
    private String id;
    private String serviceName;
    private Double unitPrice;
    private String unit;
    private String calcMethod;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
