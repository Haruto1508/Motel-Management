package vn.edu.fpt.motelbackend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceRequest;
import vn.edu.fpt.motelbackend.dto.invoice.InvoiceResponse;
import vn.edu.fpt.motelbackend.dto.invoice.PaymentRequest;
import vn.edu.fpt.motelbackend.dto.invoice.PaymentResponse;
import vn.edu.fpt.motelbackend.entity.*;
import vn.edu.fpt.motelbackend.repository.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final InvoicePaymentRepository invoicePaymentRepository;
    private final RoomRepository roomRepository;
    private final ContractRepository contractRepository;

    public List<InvoiceResponse> getInvoices(String roomId, String billingMonth, String status, String query) {
        String cleanRoomId = (roomId != null && !roomId.trim().isEmpty()) ? roomId.trim() : null;
        String cleanMonth = (billingMonth != null && !billingMonth.trim().isEmpty()) ? billingMonth.trim() : null;
        String cleanStatus = (status != null && !status.trim().isEmpty()) ? status.trim().toUpperCase() : null;
        String cleanQuery = (query != null && !query.trim().isEmpty()) ? query.trim() : null;

        return invoiceRepository.findWithFilters(cleanRoomId, cleanMonth, cleanStatus, cleanQuery)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public InvoiceResponse getInvoiceById(String id) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hóa đơn với ID: " + id));
        return mapToResponse(invoice);
    }

    @Transactional
    public InvoiceResponse createInvoice(InvoiceRequest request) {
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phòng với ID: " + request.getRoomId()));

        Optional<Contract> contractOpt = contractRepository.findFirstByRoomIdAndStatus(room.getId(), "ACTIVE");
        String tenantName = contractOpt.map(c -> c.getPrimaryTenant().getFullName()).orElse("Khách thuê phòng " + room.getRoomCode());

        double roomAmt = request.getRoomAmount();
        double elecAmt = request.getElectricityAmount() != null ? request.getElectricityAmount() : 0.0;
        double waterAmt = request.getWaterAmount() != null ? request.getWaterAmount() : 0.0;
        double svcAmt = request.getServiceAmount() != null ? request.getServiceAmount() : 0.0;
        double discountAmt = request.getDiscountAmount() != null ? request.getDiscountAmount() : 0.0;
        double otherAmt = request.getOtherAmount() != null ? request.getOtherAmount() : 0.0;

        double totalAmt = Math.max(0, roomAmt + elecAmt + waterAmt + svcAmt + otherAmt - discountAmt);

        String monthDigits = request.getBillingMonth().replace("/", "");
        String invoiceNumber = "INV-" + monthDigits + "-" + room.getRoomCode() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();

        Invoice invoice = Invoice.builder()
                .invoiceNumber(invoiceNumber)
                .room(room)
                .billingMonth(request.getBillingMonth())
                .tenantName(tenantName)
                .roomAmount(roomAmt)
                .electricityAmount(elecAmt)
                .waterAmount(waterAmt)
                .serviceAmount(svcAmt)
                .discountAmount(discountAmt)
                .otherAmount(otherAmt)
                .totalAmount(totalAmt)
                .paidAmount(0.0)
                .status("UNPAID")
                .dueDate(request.getDueDate())
                .build();

        return mapToResponse(invoiceRepository.save(invoice));
    }

    @Transactional
    public InvoiceResponse updateInvoice(String id, InvoiceRequest request) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hóa đơn với ID: " + id));

        if (request.getRoomAmount() != null) invoice.setRoomAmount(request.getRoomAmount());
        if (request.getElectricityAmount() != null) invoice.setElectricityAmount(request.getElectricityAmount());
        if (request.getWaterAmount() != null) invoice.setWaterAmount(request.getWaterAmount());
        if (request.getServiceAmount() != null) invoice.setServiceAmount(request.getServiceAmount());
        if (request.getDiscountAmount() != null) invoice.setDiscountAmount(request.getDiscountAmount());
        if (request.getOtherAmount() != null) invoice.setOtherAmount(request.getOtherAmount());
        if (request.getDueDate() != null) invoice.setDueDate(request.getDueDate());

        double total = Math.max(0, invoice.getRoomAmount() + invoice.getElectricityAmount() + invoice.getWaterAmount() +
                invoice.getServiceAmount() + invoice.getOtherAmount() - invoice.getDiscountAmount());
        invoice.setTotalAmount(total);

        updateInvoiceStatus(invoice);

        return mapToResponse(invoiceRepository.save(invoice));
    }

    @Transactional
    public void cancelInvoice(String id) {
        Invoice invoice = invoiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hóa đơn với ID: " + id));

        invoice.setStatus("CANCELLED");
        invoiceRepository.save(invoice);
    }

    @Transactional
    public PaymentResponse recordPayment(PaymentRequest request) {
        Invoice invoice = invoiceRepository.findById(request.getInvoiceId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hóa đơn với ID: " + request.getInvoiceId()));

        if (request.getAmount() <= 0) {
            throw new IllegalArgumentException("Số tiền thanh toán phải lớn hơn 0");
        }

        InvoicePayment payment = InvoicePayment.builder()
                .invoice(invoice)
                .amount(request.getAmount())
                .paymentMethod(request.getPaymentMethod() != null ? request.getPaymentMethod() : "CASH")
                .notes(request.getNotes())
                .paymentDate(request.getPaymentDate() != null ? request.getPaymentDate() : LocalDateTime.now())
                .build();

        InvoicePayment saved = invoicePaymentRepository.save(payment);

        double newPaid = (invoice.getPaidAmount() != null ? invoice.getPaidAmount() : 0.0) + request.getAmount();
        invoice.setPaidAmount(newPaid);
        updateInvoiceStatus(invoice);
        invoiceRepository.save(invoice);

        return PaymentResponse.builder()
                .id(saved.getId())
                .invoiceId(invoice.getId())
                .amount(saved.getAmount())
                .paymentMethod(saved.getPaymentMethod())
                .paymentDate(saved.getPaymentDate())
                .notes(saved.getNotes())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    public List<PaymentResponse> getPaymentsByInvoiceId(String invoiceId) {
        return invoicePaymentRepository.findByInvoiceIdOrderByPaymentDateDesc(invoiceId)
                .stream()
                .map(p -> PaymentResponse.builder()
                        .id(p.getId())
                        .invoiceId(p.getInvoice().getId())
                        .amount(p.getAmount())
                        .paymentMethod(p.getPaymentMethod())
                        .paymentDate(p.getPaymentDate())
                        .notes(p.getNotes())
                        .createdAt(p.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    private void updateInvoiceStatus(Invoice invoice) {
        if ("CANCELLED".equals(invoice.getStatus())) return;

        double paid = invoice.getPaidAmount() != null ? invoice.getPaidAmount() : 0.0;
        double total = invoice.getTotalAmount();

        if (paid >= total) {
            invoice.setStatus("PAID");
        } else if (paid > 0) {
            invoice.setStatus("PARTIAL");
        } else {
            if (invoice.getDueDate() != null && invoice.getDueDate().isBefore(LocalDateTime.now())) {
                invoice.setStatus("OVERDUE");
            } else {
                invoice.setStatus("UNPAID");
            }
        }
    }

    private InvoiceResponse mapToResponse(Invoice i) {
        double paid = i.getPaidAmount() != null ? i.getPaidAmount() : 0.0;
        double remaining = Math.max(0, i.getTotalAmount() - paid);

        return InvoiceResponse.builder()
                .id(i.getId())
                .invoiceNumber(i.getInvoiceNumber())
                .roomId(i.getRoom().getId())
                .roomCode(i.getRoom().getRoomCode())
                .tenantName(i.getTenantName())
                .billingMonth(i.getBillingMonth())
                .roomAmount(i.getRoomAmount())
                .electricityAmount(i.getElectricityAmount())
                .waterAmount(i.getWaterAmount())
                .serviceAmount(i.getServiceAmount())
                .discountAmount(i.getDiscountAmount())
                .otherAmount(i.getOtherAmount())
                .totalAmount(i.getTotalAmount())
                .paidAmount(paid)
                .remainingAmount(remaining)
                .status(i.getStatus())
                .dueDate(i.getDueDate())
                .createdAt(i.getCreatedAt())
                .updatedAt(i.getUpdatedAt())
                .build();
    }
}
