package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.InvoicePayment;

import java.util.List;

@Repository
public interface InvoicePaymentRepository extends JpaRepository<InvoicePayment, String> {
    List<InvoicePayment> findByInvoiceIdOrderByPaymentDateDesc(String invoiceId);
}
