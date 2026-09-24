package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.Room;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomRepository extends JpaRepository<Room, String> {
    Optional<Room> findByRoomCode(String roomCode);

    @Query("SELECT r FROM Room r WHERE " +
           "(:query IS NULL OR LOWER(r.name) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(r.roomCode) LIKE LOWER(CONCAT('%', :query, '%'))) AND " +
           "(:status IS NULL OR r.status = :status) AND " +
           "(:floor IS NULL OR r.floor = :floor) " +
           "ORDER BY r.floor ASC, r.roomCode ASC")
    List<Room> findWithFilters(@Param("query") String query,
                               @Param("status") String status,
                               @Param("floor") Integer floor);

    long countByStatus(String status);
}
