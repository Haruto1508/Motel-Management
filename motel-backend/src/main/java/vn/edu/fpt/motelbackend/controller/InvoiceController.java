package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceRequest;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceResponse;
import vn.edu.fpt.motelbackend.service.InvoiceService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<InvoiceResponse>>> getInvoices(
            @RequestParam(required = false) String roomId,
            @RequestParam(required = false) String billingMonth,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String query) {
        List<InvoiceResponse> invoices = invoiceService.getInvoices(roomId, billingMonth, status, query);
        return ResponseEntity.ok(ApiResponse.ok(invoices));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<InvoiceResponse>> getInvoiceById(@PathVariable String id) {
        InvoiceResponse invoice = invoiceService.getInvoiceById(id);
        return ResponseEntity.ok(ApiResponse.ok(invoice));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<InvoiceResponse>> createInvoice(@Valid @RequestBody InvoiceRequest request) {
        InvoiceResponse invoice = invoiceService.createInvoice(request);
        return ResponseEntity.ok(ApiResponse.ok(invoice, "Lập hóa đơn thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<InvoiceResponse>> updateInvoice(
            @PathVariable String id,
            @RequestBody InvoiceRequest request) {
        InvoiceResponse invoice = invoiceService.updateInvoice(id, request);
        return ResponseEntity.ok(ApiResponse.ok(invoice, "Cập nhật hóa đơn thành công"));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelInvoice(@PathVariable String id) {
        invoiceService.cancelInvoice(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Đã hủy hóa đơn"));
    }
}
