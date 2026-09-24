package vn.edu.fpt.motelbackend.dto.room;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.edu.fpt.motelbackend.dto.contract.ContractResponse;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceResponse;
import vn.edu.fpt.motelbackend.dto.utility.UtilityReadingResponse;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomDetailResponse {
    private RoomResponse room;
    @Builder.Default
    private List<RoomMemberResponse> members = new ArrayList<>();
    private ContractResponse activeContract;
    private UtilityReadingResponse latestUtilities;
    private InvoiceResponse currentInvoice;
}
