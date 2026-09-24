package vn.edu.fpt.motelbackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.motelbackend.entity.RoomMember;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomMemberRepository extends JpaRepository<RoomMember, String> {
    List<RoomMember> findByRoomId(String roomId);
    List<RoomMember> findByTenantId(String tenantId);
    Optional<RoomMember> findFirstByTenantId(String tenantId);
    void deleteByRoomIdAndId(String roomId, String id);
    long countByRoomId(String roomId);
}
