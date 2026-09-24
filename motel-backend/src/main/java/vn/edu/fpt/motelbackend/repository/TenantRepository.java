package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.Tenant;

import java.util.List;

@Repository
public interface TenantRepository extends JpaRepository<Tenant, String> {

    @Query("SELECT t FROM Tenant t WHERE " +
           "(:query IS NULL OR LOWER(t.fullName) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR t.phone LIKE CONCAT('%', :query, '%') " +
           "OR t.identityCard LIKE CONCAT('%', :query, '%')) AND " +
           "(:status IS NULL OR t.status = :status) " +
           "ORDER BY t.createdAt DESC")
    List<Tenant> findWithFilters(@Param("query") String query, @Param("status") String status);

    long countByStatus(String status);
}
