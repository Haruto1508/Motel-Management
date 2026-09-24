package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.UtilityReading;

import java.util.List;
import java.util.Optional;

@Repository
public interface UtilityReadingRepository extends JpaRepository<UtilityReading, String> {

    @Query("SELECT u FROM UtilityReading u WHERE " +
           "(:roomId IS NULL OR u.room.id = :roomId) AND " +
           "(:billingMonth IS NULL OR u.billingMonth = :billingMonth) " +
           "ORDER BY u.readingDate DESC")
    List<UtilityReading> findWithFilters(@Param("roomId") String roomId,
                                         @Param("billingMonth") String billingMonth);

    Optional<UtilityReading> findFirstByRoomIdOrderByReadingDateDesc(String roomId);
}
