package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.Invoice;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, String> {

    @Query("SELECT i FROM Invoice i WHERE " +
           "(:roomId IS NULL OR i.room.id = :roomId) AND " +
           "(:billingMonth IS NULL OR i.billingMonth = :billingMonth) AND " +
           "(:status IS NULL OR i.status = :status) AND " +
           "(:query IS NULL OR LOWER(i.invoiceNumber) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(i.tenantName) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(i.room.roomCode) LIKE LOWER(CONCAT('%', :query, '%'))) " +
           "ORDER BY i.dueDate DESC")
    List<Invoice> findWithFilters(@Param("roomId") String roomId,
                                  @Param("billingMonth") String billingMonth,
                                  @Param("status") String status,
                                  @Param("query") String query);

    Optional<Invoice> findFirstByRoomIdOrderByDueDateDesc(String roomId);

    @Query("SELECT COALESCE(SUM(i.totalAmount), 0) FROM Invoice i WHERE (:billingMonth IS NULL OR i.billingMonth = :billingMonth) AND i.status != 'CANCELLED'")
    Double sumTotalAmountByBillingMonth(@Param("billingMonth") String billingMonth);

    @Query("SELECT COALESCE(SUM(i.paidAmount), 0) FROM Invoice i WHERE (:billingMonth IS NULL OR i.billingMonth = :billingMonth) AND i.status != 'CANCELLED'")
    Double sumPaidAmountByBillingMonth(@Param("billingMonth") String billingMonth);
}
