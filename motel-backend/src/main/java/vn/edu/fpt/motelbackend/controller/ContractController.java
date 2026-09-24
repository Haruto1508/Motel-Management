package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.contract.ContractRequest;
import vn.edu.fpt.motelbackend.dto.contract.ContractResponse;
import vn.edu.fpt.motelbackend.dto.contract.RenewContractRequest;
import vn.edu.fpt.motelbackend.dto.contract.TerminateContractRequest;
import vn.edu.fpt.motelbackend.service.ContractService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/contracts")
@RequiredArgsConstructor
public class ContractController {

    private final ContractService contractService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ContractResponse>>> getContracts(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String status) {
        List<ContractResponse> contracts = contractService.getContracts(query, status);
        return ResponseEntity.ok(ApiResponse.ok(contracts));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ContractResponse>> getContractById(@PathVariable String id) {
        ContractResponse contract = contractService.getContractById(id);
        return ResponseEntity.ok(ApiResponse.ok(contract));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ContractResponse>> createContract(@Valid @RequestBody ContractRequest request) {
        ContractResponse contract = contractService.createContract(request);
        return ResponseEntity.ok(ApiResponse.ok(contract, "Tạo hợp đồng thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ContractResponse>> updateContract(
            @PathVariable String id,
            @Valid @RequestBody ContractRequest request) {
        ContractResponse contract = contractService.updateContract(id, request);
        return ResponseEntity.ok(ApiResponse.ok(contract, "Cập nhật hợp đồng thành công"));
    }

    @PostMapping("/{id}/terminate")
    public ResponseEntity<ApiResponse<Void>> terminateContract(
            @PathVariable String id,
            @RequestBody(required = false) TerminateContractRequest request) {
        contractService.terminateContract(id, request != null ? request : new TerminateContractRequest());
        return ResponseEntity.ok(ApiResponse.ok(null, "Thanh lý hợp đồng thành công"));
    }

    @PostMapping("/{id}/renew")
    public ResponseEntity<ApiResponse<ContractResponse>> renewContract(
            @PathVariable String id,
            @Valid @RequestBody RenewContractRequest request) {
        ContractResponse contract = contractService.renewContract(id, request);
        return ResponseEntity.ok(ApiResponse.ok(contract, "Gia hạn hợp đồng thành công"));
    }
}
