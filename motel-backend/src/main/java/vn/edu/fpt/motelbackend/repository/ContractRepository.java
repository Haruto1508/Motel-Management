package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.Contract;

import java.util.List;
import java.util.Optional;

@Repository
public interface ContractRepository extends JpaRepository<Contract, String> {

    @Query("SELECT c FROM Contract c WHERE " +
           "(:query IS NULL OR LOWER(c.contractNumber) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(c.room.roomCode) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(c.primaryTenant.fullName) LIKE LOWER(CONCAT('%', :query, '%'))) AND " +
           "(:status IS NULL OR c.status = :status) " +
           "ORDER BY c.createdAt DESC")
    List<Contract> findWithFilters(@Param("query") String query, @Param("status") String status);

    Optional<Contract> findFirstByRoomIdAndStatus(String roomId, String status);

    List<Contract> findByRoomId(String roomId);
}
