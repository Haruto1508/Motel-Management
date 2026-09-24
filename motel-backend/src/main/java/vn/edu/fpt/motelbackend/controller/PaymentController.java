package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.invoice.PaymentRequest;
import vn.edu.fpt.motelbackend.dto.invoice.PaymentResponse;
import vn.edu.fpt.motelbackend.service.InvoiceService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final InvoiceService invoiceService;

    @PostMapping
    public ResponseEntity<ApiResponse<PaymentResponse>> recordPayment(@Valid @RequestBody PaymentRequest request) {
        PaymentResponse payment = invoiceService.recordPayment(request);
        return ResponseEntity.ok(ApiResponse.ok(payment, "Ghi nhận thanh toán thành công"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<PaymentResponse>>> getPayments(@RequestParam String invoiceId) {
        List<PaymentResponse> payments = invoiceService.getPaymentsByInvoiceId(invoiceId);
        return ResponseEntity.ok(ApiResponse.ok(payments));
    }
}
